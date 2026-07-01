import pandas as pd

input_file = '/Users/umutsarikaya/lmsi_project/data/raw/wage_price_index/wpi_table05b_wages_industry_quarterly.xlsx'
output_file = '/Users/umutsarikaya/lmsi_project/data/processed/wpi_industry_long.csv'

print("Reading file...")
df = pd.read_excel(input_file, sheet_name='Data1', header=0)

# Rename first column to date
df = df.rename(columns={df.columns[0]: 'date'})

# Drop metadata rows
df = df[pd.to_datetime(df['date'], errors='coerce').notna()].copy()

# Format date as quarter
df['date'] = pd.to_datetime(df['date']).dt.to_period('Q').astype(str)

# Keep only year-on-year % change columns for Private and Public
cols_to_keep = ['date'] + [
    col for col in df.columns
    if 'Percentage Change from Corresponding Quarter of Previous Year' in str(col)
    and 'Private and Public' in str(col)
]
if len(cols_to_keep) == 1:
    raise ValueError("No matching WPI growth columns found. Check column names.")
df = df[cols_to_keep]

# Wide to long
df_long = df.melt(id_vars='date', var_name='series_label', value_name='wpi_growth')

# Standardise industry labels
def clean_industry(label):
    label = str(label).lower()
    if 'health care' in label: return 'Health Care and Social Assistance'
    if 'construction' in label: return 'Construction'
    if 'professional, scientific and technical' in label: return 'Professional, Scientific and Technical Services'
    if 'education and training' in label: return 'Education and Training'
    if 'accommodation and food' in label: return 'Accommodation and Food Services'
    if 'manufacturing' in label: return 'Manufacturing'
    return None

df_long['industry'] = df_long['series_label'].apply(clean_industry)

# Keep only our 6 industries
df_filtered = df_long[df_long['industry'].notna()].copy()
df_filtered['wpi_growth'] = pd.to_numeric(df_filtered['wpi_growth'], errors='coerce')
df_final = df_filtered[['date', 'industry', 'wpi_growth']].dropna()

df_final.to_csv(output_file, index=False)

print(f"Done. {len(df_final)} rows written.")
print(f"\nUnique industries: {df_final['industry'].unique()}")
print(f"Date range: {df_final['date'].min()} to {df_final['date'].max()}")
print(f"\nFirst 10 rows:")
print(df_final.head(10))
