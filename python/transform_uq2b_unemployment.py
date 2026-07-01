import pandas as pd

input_file = '/Users/umutsarikaya/lmsi_project/data/raw/labour_force/lf_uq2b_unemployed_industry_state.xlsx'
output_file = '/Users/umutsarikaya/lmsi_project/data/processed/uq2b_unemployment_long.csv'

print("Reading file...")
df = pd.read_excel(input_file, sheet_name='Data 1', skiprows=2)
df.columns = ['date', 'state', 'industry', 'weeks_searching', 'unemployed_ft', 'unemployed_pt'] + list(df.columns[6:])

states = ['New South Wales', 'Victoria', 'Queensland']
industries = [
    'Health Care and Social Assistance',
    'Construction',
    'Education and Training',
    'Accommodation and Food Services',
    'Manufacturing',
    'Professional, Scientific and Technical Services',
]

df = df[df['state'].isin(states)].copy()
df = df[df['industry'].isin(industries)].copy()

df['unemployed_ft'] = pd.to_numeric(df['unemployed_ft'], errors='coerce')
df['unemployed_pt'] = pd.to_numeric(df['unemployed_pt'], errors='coerce')
df['unemployed_thousands'] = df['unemployed_ft'] + df['unemployed_pt']
df['date'] = pd.to_datetime(df['date']).dt.to_period('Q').astype(str)

df = df[df['unemployed_thousands'].notna()]

df_final = df.groupby(['date', 'state', 'industry'])['unemployed_thousands'].sum().reset_index()

df_final.to_csv(output_file, index=False)

print(f"Done. {len(df_final)} rows written.")
print(f"States: {df_final['state'].unique()}")
print(f"Industries: {df_final['industry'].unique()}")
print(f"Date range: {df_final['date'].min()} to {df_final['date'].max()}")
print(df_final.head(6))