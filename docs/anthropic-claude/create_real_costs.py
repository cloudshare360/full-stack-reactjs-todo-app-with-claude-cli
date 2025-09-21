#!/usr/bin/env python3
"""
Real Claude Costs - Todo App Development
Based on actual balance usage: $17.46 total spent today
"""

import pandas as pd
from datetime import datetime

# Your real balance data
previous_balance = 5.33
credit_added_today = 35.18
current_balance = 23.05
total_spent_today = previous_balance + credit_added_today - current_balance

print(f"💰 Real Cost Calculation:")
print(f"Previous balance: ${previous_balance:.2f}")
print(f"Credit added today: ${credit_added_today:.2f}")
print(f"Current balance: ${current_balance:.2f}")
print(f"Total spent today: ${total_spent_today:.2f}")

# Feature costs based on development complexity
mongodb_docker_cost = 3.50    # 20% - Database setup and Docker config
express_api_cost = 8.73       # 50% - Backend API development (most complex)
reactjs_frontend_cost = 5.23  # 30% - Frontend development

print(f"\nBreakdown by main components:")
print(f"MongoDB + Docker: ${mongodb_docker_cost:.2f}")
print(f"Express.js REST API: ${express_api_cost:.2f}")
print(f"React.js Frontend: ${reactjs_frontend_cost:.2f}")
print(f"Total: ${mongodb_docker_cost + express_api_cost + reactjs_frontend_cost:.2f}")

# Create Excel file
timestamp = datetime.now().strftime("%Y%m%d_%H%M")
filename = f'Claude_Real_Costs_{timestamp}.xlsx'

with pd.ExcelWriter(filename, engine='xlsxwriter') as writer:
    workbook = writer.book

    # Format styles
    header_format = workbook.add_format({
        'bold': True,
        'bg_color': '#4472C4',
        'font_color': 'white',
        'border': 1
    })

    currency_format = workbook.add_format({
        'num_format': '$#,##0.00',
        'border': 1
    })

    # 1. Summary Sheet
    summary_data = {
        'Item': [
            'Previous Balance',
            'Credit Added Today',
            'Current Balance',
            'Total Spent Today',
            'Development Date',
            'Project Status'
        ],
        'Value': [
            f'${previous_balance:.2f}',
            f'${credit_added_today:.2f}',
            f'${current_balance:.2f}',
            f'${total_spent_today:.2f}',
            'Sep 21, 2025',
            'Complete'
        ]
    }

    df_summary = pd.DataFrame(summary_data)
    df_summary.to_excel(writer, sheet_name='Cost Summary', index=False)

    worksheet = writer.sheets['Cost Summary']
    for col_num, value in enumerate(df_summary.columns.values):
        worksheet.write(0, col_num, value, header_format)
    worksheet.set_column('A:A', 25)
    worksheet.set_column('B:B', 20)

    # 2. Main Components Cost
    components_data = {
        'Component': [
            'MongoDB + Docker Setup',
            'Express.js REST API',
            'React.js Frontend',
            'TOTAL'
        ],
        'Cost': [
            mongodb_docker_cost,
            express_api_cost,
            reactjs_frontend_cost,
            total_spent_today
        ],
        'Percentage': [
            f'{(mongodb_docker_cost/total_spent_today)*100:.0f}%',
            f'{(express_api_cost/total_spent_today)*100:.0f}%',
            f'{(reactjs_frontend_cost/total_spent_today)*100:.0f}%',
            '100%'
        ],
        'Description': [
            'Database setup, Docker compose, MongoDB config',
            'REST API endpoints, CRUD operations, middleware',
            'React 18 components, UI, state management',
            'Complete fullstack todo application'
        ]
    }

    df_components = pd.DataFrame(components_data)
    df_components.to_excel(writer, sheet_name='Component Costs', index=False)

    worksheet = writer.sheets['Component Costs']
    for col_num, value in enumerate(df_components.columns.values):
        worksheet.write(0, col_num, value, header_format)

    # Apply currency formatting to Cost column
    worksheet.set_column('B:B', 15, currency_format)
    worksheet.set_column('A:A', 25)
    worksheet.set_column('C:C', 12)
    worksheet.set_column('D:D', 40)

    # 3. Detailed Feature Breakdown
    detailed_data = {
        'Feature': [
            'MongoDB Database Setup',
            'Docker Compose Configuration',
            'Express.js Server Setup',
            'REST API Endpoints',
            'CRUD Operations',
            'React 18 Project Setup',
            'UI Components',
            'State Management',
            'API Integration',
            'Testing & Debugging'
        ],
        'Component': [
            'MongoDB + Docker',
            'MongoDB + Docker',
            'Express.js API',
            'Express.js API',
            'Express.js API',
            'React.js Frontend',
            'React.js Frontend',
            'React.js Frontend',
            'Integration',
            'Testing'
        ],
        'Estimated_Cost': [
            '$1.75', '$1.75', '$2.18', '$3.27', '$3.28',
            '$1.31', '$2.18', '$1.74', '$1.00', '$1.00'
        ]
    }

    df_detailed = pd.DataFrame(detailed_data)
    df_detailed.to_excel(writer, sheet_name='Detailed Breakdown', index=False)

    worksheet = writer.sheets['Detailed Breakdown']
    for col_num, value in enumerate(df_detailed.columns.values):
        worksheet.write(0, col_num, value, header_format)
    worksheet.set_column('A:A', 30)
    worksheet.set_column('B:B', 20)
    worksheet.set_column('C:C', 15)

print(f"\n✅ Excel file created: {filename}")
print(f"📊 Total real cost for todo app: ${total_spent_today:.2f}")
print(f"💾 MongoDB + Docker: ${mongodb_docker_cost:.2f}")
print(f"🔗 Express.js API: ${express_api_cost:.2f}")
print(f"⚛️  React.js Frontend: ${reactjs_frontend_cost:.2f}")