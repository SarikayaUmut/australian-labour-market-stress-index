import pandas as pd

input_file = '/Users/umutsarikaya/lmsi_project/data/raw/job_vacancies/jv_table04_vacancies_industry.xlsx'
output_file = '/Users/umutsarikaya/lmsi_project/data/processed/jv_table04_long.csv'

print("Reading file...")
df = pd.read_excel(input_file, sheet_name='Data1', header=0)

# Rename first column to date
df = df.rename(columns={df.columns[0]: 'date'})

# Keep only Job Vacancies columns, drop Standard Error columns
df = df[[col for col in df.columns if 'Standard Error' not in str(col)]]

# Drop metadata rows, keep only actual date rows
df = df[pd.to_datetime(df['date'], errors='coerce').notna()].copy()

# Format date as quarter
df['date'] = pd.to_datetime(df['date']).dt.to_period('Q').astype(str)

# Wide to long
df_long = df.melt(id_vars='date', var_name='series_label', value_name='vacancies_thousands')

# Standardise industry labels
def clean_industry(label):
    label = str(label).replace('Job Vacancies ;', '').strip().strip(';').strip()
    if 'Health Care' in label: return 'Health Care and Social Assistance'
    if 'Construction' in label: return 'Construction'
    if 'Professional, Scientific' in label: return 'Professional, Scientific and Technical Services'
    if 'Education and Training' in label: return 'Education and Training'
    if 'Accommodation' in label: return 'Accommodation and Food Services'
    if 'Manufacturing' in label: return 'Manufacturing'
    return None

df_long['industry'] = df_long['series_label'].apply(clean_industry)

# Keep only our 6 industries
df_filtered = df_long[df_long['industry'].notna()].copy()
df_filtered['vacancies_thousands'] = pd.to_numeric(df_filtered['vacancies_thousands'], errors='coerce')
df_final = df_filtered[['date', 'industry', 'vacancies_thousands']].dropna()

df_final.to_csv(output_file, index=False)

print(f"Done. {len(df_final)} rows written.")
print(f"Date range: {df_final['date'].min()} to {df_final['date'].max()}")
print(f"\nUnique industries: {df_final['industry'].unique()}")
print(f"\nFirst 10 rows:")
print(df_final.head(10))
