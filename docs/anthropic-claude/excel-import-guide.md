# Excel Import Guide for Claude Cost Analysis

This guide explains how to import the CSV files into Excel to create a comprehensive cost analysis workbook.

## 📊 Files Created

The following CSV files have been created in the `docs/anthropic-claude/` directory:

1. **executive-summary.csv** - High-level project metrics
2. **feature-cost-breakdown.csv** - Detailed cost analysis per feature
3. **time-investment-analysis.csv** - Session-by-session time tracking
4. **roi-calculation.csv** - Return on investment analysis
5. **quality-metrics.csv** - Quality scores and metrics
6. **budget-vs-actual.csv** - Budget variance analysis
7. **cost-optimization-tracking.csv** - Optimization strategies and impact
8. **monthly-tracking-template.csv** - Template for ongoing tracking

## 🚀 Quick Excel Import (Option 1)

### Step 1: Create New Excel Workbook
1. Open Microsoft Excel
2. Create a new blank workbook
3. Save as "Claude-Cost-Analysis.xlsx"

### Step 2: Import Each CSV as Separate Worksheet
1. **Data** → **Get Data** → **From File** → **From Text/CSV**
2. Select each CSV file one by one
3. Import each as a separate worksheet
4. Rename worksheets to match the content:
   - Executive Summary
   - Feature Costs
   - Time Analysis
   - ROI Calculation
   - Quality Metrics
   - Budget Analysis
   - Optimization
   - Monthly Tracking

### Step 3: Format the Data
1. Apply **Table** formatting to each worksheet
2. Add **Conditional Formatting** for status indicators
3. Create **Charts** for visual analysis

## 🐍 Automated Excel Creation (Option 2)

Use the Python script below to automatically create a formatted Excel workbook:

```python
import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.chart import BarChart, LineChart, PieChart, Reference
import os

def create_excel_workbook():
    # Dictionary mapping CSV files to worksheet names
    csv_files = {
        'executive-summary.csv': 'Executive Summary',
        'feature-cost-breakdown.csv': 'Feature Costs',
        'time-investment-analysis.csv': 'Time Analysis',
        'roi-calculation.csv': 'ROI Calculation',
        'quality-metrics.csv': 'Quality Metrics',
        'budget-vs-actual.csv': 'Budget Analysis',
        'cost-optimization-tracking.csv': 'Optimization',
        'monthly-tracking-template.csv': 'Monthly Tracking'
    }

    # Create Excel writer
    with pd.ExcelWriter('Claude-Cost-Analysis.xlsx', engine='openpyxl') as writer:

        for csv_file, sheet_name in csv_files.items():
            if os.path.exists(csv_file):
                # Read CSV file
                df = pd.read_csv(csv_file)

                # Write to Excel
                df.to_excel(writer, sheet_name=sheet_name, index=False)

                # Get the worksheet for formatting
                worksheet = writer.sheets[sheet_name]

                # Apply formatting
                header_font = Font(bold=True, color="FFFFFF")
                header_fill = PatternFill(start_color="366092", end_color="366092", fill_type="solid")

                # Format header row
                for cell in worksheet[1]:
                    cell.font = header_font
                    cell.fill = header_fill
                    cell.alignment = Alignment(horizontal="center")

                # Auto-adjust column widths
                for column in worksheet.columns:
                    max_length = 0
                    column_letter = column[0].column_letter

                    for cell in column:
                        try:
                            if len(str(cell.value)) > max_length:
                                max_length = len(str(cell.value))
                        except:
                            pass

                    adjusted_width = min(max_length + 2, 50)
                    worksheet.column_dimensions[column_letter].width = adjusted_width

    print("✅ Excel workbook 'Claude-Cost-Analysis.xlsx' created successfully!")

if __name__ == "__main__":
    create_excel_workbook()
```

### To run the Python script:
1. **Install required packages**:
   ```bash
   pip install pandas openpyxl
   ```

2. **Save script as `create_excel.py`** in the same directory as CSV files

3. **Run the script**:
   ```bash
   python create_excel.py
   ```

## 📈 Excel Dashboard Creation

### Step 1: Create Summary Dashboard
1. Insert new worksheet named "Dashboard"
2. Create summary cards showing:
   - Total Project Cost: $8,500
   - Total Savings: $9,500
   - ROI: 206%
   - Time Savings: 81%

### Step 2: Add Charts
1. **Cost Breakdown Pie Chart** (from Feature Costs sheet)
2. **ROI by Feature Bar Chart** (from Feature Costs sheet)
3. **Time vs Cost Trend Line** (from Time Analysis sheet)
4. **Quality Metrics Spider Chart** (from Quality Metrics sheet)

### Step 3: Interactive Elements
1. Add **Slicers** for filtering by feature or date
2. Create **Pivot Tables** for dynamic analysis
3. Add **Data Validation** dropdowns for scenarios

## 🎨 Formatting Recommendations

### Color Scheme
- **Headers**: Dark Blue (#366092)
- **Success/Positive**: Green (#70AD47)
- **Warning**: Orange (#FFC000)
- **Critical**: Red (#C5504B)
- **Neutral**: Gray (#A5A5A5)

### Conditional Formatting Rules
- **ROI > 200%**: Green background
- **ROI 150-200%**: Light green background
- **ROI 100-150%**: Yellow background
- **ROI < 100%**: Light red background

### Number Formats
- **Currency**: $#,##0
- **Percentages**: 0.0%
- **Hours**: 0.0 "hours"
- **Dates**: mm/dd/yyyy

## 📊 Key Formulas for Excel

### Dashboard Summary Formulas
```excel
=SUM('Feature Costs'!E:E)          // Total Claude Cost
=SUM('Feature Costs'!G:G)          // Total Traditional Cost
=SUM('Feature Costs'!H:H)          // Total Savings
=AVERAGE('Feature Costs'!J:J)      // Average ROI
=SUM('Time Analysis'!F:F)          // Total Hours
=AVERAGE('Quality Metrics'!B:B)    // Average Quality Score
```

### Trend Analysis
```excel
=TREND('Time Analysis'!F:F,'Time Analysis'!A:A)  // Time trend
=FORECAST.LINEAR(A2,'Feature Costs'!E:E,'Feature Costs'!C:C)  // Cost forecast
```

## 🔄 Updating the Analysis

### For Ongoing Projects:
1. **Use Monthly Tracking sheet** to add new entries
2. **Update formulas** to include new data ranges
3. **Refresh charts** to show latest data
4. **Export updated CSV** files for backup

### When Adding New Features:
1. **Add rows** to Feature Costs sheet
2. **Update totals** and averages
3. **Refresh dashboard** calculations
4. **Update charts** with new data ranges

## 📱 Mobile Excel Access

The Excel file will work with:
- **Excel Mobile App** (iOS/Android)
- **Excel Online** (web browser)
- **Excel Desktop** (Windows/Mac)

All formatting and charts will be preserved across platforms.

## ✅ Validation Checklist

After creating the Excel workbook:
- [ ] All 8 CSV files imported successfully
- [ ] Headers formatted consistently
- [ ] Numbers display correctly (currency, percentages)
- [ ] Charts update with data changes
- [ ] Dashboard shows correct totals
- [ ] Conditional formatting working
- [ ] File saves without errors
- [ ] Data validation rules applied

## 🎯 Next Steps

1. **Create the Excel workbook** using one of the methods above
2. **Review and validate** all imported data
3. **Customize formatting** to match your preferences
4. **Add additional charts** as needed
5. **Share with stakeholders** for review
6. **Set up regular updates** using the monthly tracking template

The Excel workbook will provide a professional, interactive cost analysis that you can use for reporting, budgeting, and future project planning.