##########################################
# Script to clean the .xlsx file with data from the lottery results
# Author: Fred Milhome
##########################################

# Setup
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.nonparametric.smoothers_lowess import lowess
import statsmodels.api as sm

# Load data
df = pd.read_csv('data/processed/mega_sena_cleaned.csv')

# Item (a): announcement elasticity of revenue

# Dataframe for log-log regression
reg_df = df[['arrecadacao_total', 'estimativa_premio']].copy()
# Enforce numeric type
reg_df = reg_df.apply(pd.to_numeric, errors='coerce')
# Filter possible NAs
reg_df = reg_df[(reg_df['arrecadacao_total'] > 0) & (reg_df['estimativa_premio'] > 0)].dropna()

# Take logs
log_y = np.log(reg_df['arrecadacao_total'])
log_x = sm.add_constant(np.log(reg_df['estimativa_premio']))

ols = sm.OLS(log_y, log_x).fit()

# Export LaTeX table (estimates and standard errors only)
coef_table = ols.summary2(
    title='Log-Log Regression: Revenue on Announced Prize',
    yname=r'$\ln(\text{Revenue})$',
    xname=[r'Constant', r'$\ln(\text{Announced Prize})$'],
    alpha=0.05,
).tables[1][['Coef.', 'Std.Err.']]

latex_table = coef_table.to_latex(
    float_format='{:.4f}'.format,
    escape=False,
)

with open('output/tables/reg_revenue_prize.tex', 'w') as f:
    f.write(latex_table)

print(ols.summary2(
    yname='ln(revenue)',
    xname=['Constant', 'ln(announced_prize)'],
))


# Item (e): Compute the expected gross ROI given the announced price
x = df['estimativa_premio'].to_numpy(dtype=float)
y = df['roi'].to_numpy(dtype=float)

result = lowess(y, x, frac=0.2, return_sorted=True)
x_s, y1 = result[:, 0], result[:, 1]

fig, ax = plt.subplots()
ax.plot(x, y, '+', markersize=1.5, color='gray', label='Observations')
ax.plot(x_s, y1, label='Local linear (LOWESS)')
ax.set_xlabel('Announced Prize (R$)')
ax.set_ylabel('ROI')
ax.legend()
plt.tight_layout()
plt.savefig('output/figures/roi_vs_prize.png')
plt.show()