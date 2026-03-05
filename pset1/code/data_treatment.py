##########################################
# Script to clean the .xlsx file with data from the lottery results
# Author: Fred Milhome
##########################################

import re
import unicodedata
import pandas as pd
import numpy as np

#region Data cleaning

##########################################
# Clean results data
##########################################

# Define function to convert arbitrary strings to machine-friendly column names
# We can tell what type must be passed, as well as what it will return.
def make_machine_name(s: str) -> str:
	if s is None:
		return ''
	s = str(s)
	# Normalize to NFKD form to separate accents from letters
	s = unicodedata.normalize('NFKD', s)
	# Remove combining characters (accents)
	s = ''.join(ch for ch in s if not unicodedata.combining(ch))
	# Lowercase
	s = s.lower()
	# Replace non-alphanumeric characters (e.g. spaces and slashes) with underscores
	s = re.sub(r"[^a-z0-9]+", "_", s)
	# Replace multiple underscores with a single one
	s = re.sub(r"__+", "_", s)
	# Strip leading/trailing underscores
	s = s.strip('_')
	return s

# Define function to deal with R$ in the monetary values
def parse_brl_currency(x: str) -> float:
	if pd.isna(x):
		return pd.NA
	s = str(x).strip()
	if s == '':
		return pd.NA
	# Remove currency symbol and spaces
	s = s.replace('R$', '').replace('r$', '')
	s = s.replace(' ', '')
	# Remove thousands separator '.' and convert decimal comma to dot
	s = s.replace('.', '').replace(',', '.')
	try:
		return float(s)
	except Exception:
		return pd.NA


# Read the .xlsx file into a DataFrame
df = pd.read_excel('data/raw/Mega-Sena.xlsx', engine='openpyxl')

# Save original column names
orig_cols = list(df.columns)

# Drop unused columns about the specific draw, location of winners, and observations 
to_drop_idxs = [2, 3, 4, 5, 6, 7, 9, 19]
to_drop = [orig_cols[i] for i in to_drop_idxs if i < len(orig_cols)]
if to_drop :
	df.drop(columns=to_drop, inplace=True)

# Parse the lottery date column and filter by date
date_idx = 1
if date_idx < len(orig_cols):
	date_col_orig = orig_cols[date_idx]
	if date_col_orig not in to_drop and date_col_orig in df.columns:
		# Expecting format DD/MM/YYYY — parse with dayfirst
		df[date_col_orig] = pd.to_datetime(df[date_col_orig], dayfirst=True, errors='coerce')
		# Normalize to midnight and keep as datetime64[ns]
		df[date_col_orig] = df[date_col_orig].dt.normalize()
		# Keep only draws after June 2009 and before 25/02/2026
		df = df[(df[date_col_orig] > '2009-06-30') & (df[date_col_orig] < '2026-02-25')]
		df = df.reset_index(drop=True)

# Build a map of original -> machine name
remaining_orig_cols = [c for c in orig_cols if c not in to_drop]
col_mapping = {orig: make_machine_name(orig) for orig in remaining_orig_cols}

# Apply the mapping to the DataFrame column names
df.rename(columns=col_mapping, inplace=True)

# Convert BRL currency strings like 'R$***.***,**' to floats.
for col in df.columns:
	try:
		sample = df[col].astype(str).head(30).str.contains(r'R\$', na=False).any()
	except Exception:
		sample = False
	if sample:
		df[col] = df[col].apply(parse_brl_currency)

# Convert columns that appear to hold "ganhadores" counts to integers.
winner_keywords = ('ganhadores',)
for col in df.columns:
	if any(k in col for k in winner_keywords):
		# remove non-digits and coerce to numeric, then to nullable integer
		cleaned = df[col].astype(str).str.replace(r"[^0-9]", "", regex=True)
		df[col] = pd.to_numeric(cleaned, errors='coerce').astype('Int64')

# For any remaining object columns that look numeric with thousand separators,
# try converting them to numeric where sensible.
for col in df.select_dtypes(include=['object']).columns:
	if df[col].astype(str).str.match(r'^[0-9\.\,\s]+$').any():
		def convert_numeric_str(val):
			s = str(val).strip()
			if ',' in s:
				# Brazilian format: dots are thousands sep, comma is decimal
				s = s.replace('.', '').replace(',', '.')
			# else: assume dot is already a decimal separator
			return s
		cleaned = df[col].apply(convert_numeric_str)
		df[col] = pd.to_numeric(cleaned, errors='coerce')

#endregion

#############################################
#region Data treatment
#############################################

# Put the announced price from the previous row in the current row
if 'estimativa_premio' in df.columns:
	df['estimativa_premio'] = df['estimativa_premio'].shift(1)

# Read the ticket price history and parse it
price_hist = pd.read_csv('data/raw/ticket_price_history.csv')
price_hist['announcement'] = pd.to_datetime(price_hist['announcement'], dayfirst=True)
price_hist = price_hist.sort_values('announcement').reset_index(drop=True)

# For each draw, find the applicable ticket price:
# the most recent announcement on or before the draw date.
# Draws before the first announcement get the earliest known price.
df['data_do_sorteio'] = pd.to_datetime(df['data_do_sorteio'])
df = df.sort_values('data_do_sorteio').reset_index(drop=True)

# merge_asof (like left join) matches each draw date to the latest announcement <= that date
df = pd.merge_asof(
	df,
	price_hist.rename(columns={'announcement': 'data_do_sorteio', 'price': 'ticket_price'}),
	on='data_do_sorteio',
	direction='backward'
)

# For draws before the first price announcement, fill with the earliest known price
earliest_price = price_hist['price'].iloc[0]
df['ticket_price'] = df['ticket_price'].fillna(earliest_price)

# Number of equivalent single bets = total revenue / current ticket price
tp = pd.to_numeric(df['ticket_price'], errors='coerce')
rev = pd.to_numeric(df['arrecadacao_total'], errors='coerce')
tp = tp.where(tp > 0, pd.NA)
ratio = rev / tp
ratio = ratio.replace([np.inf, -np.inf], pd.NA)
single = np.floor(ratio)
df['apostas_simples_num'] = pd.Series(single, index=df.index).astype('Int64')

# Compute ex-post expected payout using item (c) formula
def compute_expected_payout(row):
	""" Ex-post expected payout = (prize for 6 matches * # winners of 6 matches + 
		prize for 5 matches * # winners of 5 matches + 
		prize for 4 matches * # winners of 4 matches) / number of simple bets
	"""

	prize_6 = pd.to_numeric(row.get('rateio_6_acertos', pd.NA), errors='coerce')
	prize_5 = pd.to_numeric(row.get('rateio_5_acertos', pd.NA), errors='coerce')
	prize_4 = pd.to_numeric(row.get('rateio_4_acertos', pd.NA), errors='coerce')
	winners_6 = row.get('ganhadores_6_acertos', pd.NA)
	winners_5 = row.get('ganhadores_5_acertos', pd.NA)
	winners_4 = row.get('ganhadores_4_acertos', pd.NA)
	num_bets = row.get('apostas_simples_num', pd.NA)

	if num_bets is None or num_bets <= 0:
		return pd.NA

	expected_payout = (
		(prize_6 * winners_6 if not pd.isna(prize_6) and not pd.isna(winners_6) else 0) +
		(prize_5 * winners_5 if not pd.isna(prize_5) and not pd.isna(winners_5) else 0) +
		(prize_4 * winners_4 if not pd.isna(prize_4) and not pd.isna(winners_4) else 0)
	) / num_bets

	return expected_payout

df['expected_payout'] = df.apply(compute_expected_payout, axis=1)

# Compute the expected gross return on investment using the expected payout and ticket price
def compute_roi(row):
	""" 
	ROI = expected payout / ticket price
	"""

	expected_payout = row.get('expected_payout', pd.NA)
	ticket_price = row.get('ticket_price', pd.NA)

	if pd.isna(expected_payout) or pd.isna(ticket_price):
		return pd.NA

	roi = expected_payout / ticket_price if ticket_price > 0 else pd.NA
	return roi

df['roi'] = df.apply(compute_roi, axis=1)

# Save processed data
df.to_csv('data/processed/mega_sena_cleaned.csv', index=False)

#endregion

