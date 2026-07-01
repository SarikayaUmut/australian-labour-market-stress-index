# ANZSIC division mapping used to avoid keyword-matching errors.
# Each industry row is classified by its ANZSIC division letter code (C, E, H, M, P, Q)
# rather than keyword matching, which caused incomplete sub-industry aggregation.

import pandas as pd

input_file = '/Users/umutsarikaya/lmsi_project/data/raw/labour_force/lf_eq06_industry_state_pivot.xlsx'
output_file = '/Users/umutsarikaya/lmsi_project/data/processed/lf_eq06_long.csv'

print("Reading file...")
df = pd.read_excel(input_file, sheet_name='Data 1', skiprows=2)
df.columns = ['date', 'sex', 'state', 'industry', 'employed_ft', 'employed_pt'] + list(df.columns[6:])

df = df[df['sex'].isin(['Males', 'Females'])].copy()

states = ['New South Wales', 'Victoria', 'Queensland']
df = df[df['state'].isin(states)]

anzsic_map = {
    'C': range(110, 260),
    'E': range(300, 330),
    'H': range(440, 452),
    'M': range(690, 710),
    'P': range(800, 830),
    'Q': range(840, 900),
}

division_to_industry = {
    'C': 'Manufacturing',
    'E': 'Construction',
    'H': 'Accommodation and Food Services',
    'M': 'Professional, Scientific and Technical Services',
    'P': 'Education and Training',
    'Q': 'Health Care and Social Assistance',
}

target_divisions = set(division_to_industry.keys())

def get_division(label):
    label = str(label).strip()
    first = label[0].upper()
    if first.isalpha():
        return first if first in target_divisions else None
    try:
        code = int(label[:3])
        for div, r in anzsic_map.items():
            if code in r:
                return div
    except (ValueError, TypeError):
        pass
    return None

df['division'] = df['industry'].apply(get_division)
df = df[df['division'].notna()].copy()
df['industry_clean'] = df['division'].map(division_to_industry)
df['employed_ft'] = pd.to_numeric(df['employed_ft'], errors='coerce')
df['employed_pt'] = pd.to_numeric(df['employed_pt'], errors='coerce')
df['employed_thousands'] = df['employed_ft'] + df['employed_pt']
df = df[df['employed_thousands'].notna()] 

df['date'] = pd.to_datetime(df['date']).dt.to_period('Q').astype(str)

df_final = df.groupby(['date', 'state', 'industry_clean'])['employed_thousands'].sum().reset_index()
df_final.columns = ['date', 'state', 'industry', 'employed_thousands']

df_final.to_csv(output_file, index=False)

print(f"Done. {len(df_final)} rows written.")
print(f"\nUnique industries: {df_final['industry'].unique()}")
print(f"\nVictoria Health Care sample:")
vic_hc = df_final[(df_final['state']=='Victoria') & (df_final['industry']=='Health Care and Social Assistance')]
print(vic_hc['employed_thousands'].describe().round(1))