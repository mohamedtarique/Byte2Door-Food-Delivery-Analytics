**Project Overview**

This is an end-to-end SQL analytics project that simulates the data ecosystem of a modern food-delivery platform similar to Zomato or Swiggy.
The goal was to uncover deep business insights on customers, restaurants, orders, retention, distance-based performance, and operational efficiency.

The project follows a real-world workflow — starting from database exploration, progressing through KPI identification, and ending with advanced analytical insights.

**Understanding the Data Landscape**

The project began with a thorough exploration of the database schema.
I used INFORMATION_SCHEMA to inspect:
- All tables in the database
- Column-level metadata
- Primary keys & relationships
- Data types, missing values & duplicates

This gave me a clear map of:
Tables involved: customers, restaurants, products, orders

<img width="817" height="489" alt="image" src="https://github.com/user-attachments/assets/dd55fabc-82c2-4533-85c2-cd0d3c6cbbdc" />


1️⃣ **Key observation:**
- ~5,000 unique customers
- ~200 restaurants
- ~2,123 product entries
- ~9,060 order records
Each order row represents one item in the order (item-level granularity)


2️⃣ **Identifying Dimensions & Measures**
Next, I classified the dataset into:
*Dimensions*
- Customer demographics (age, age groups, signup date, gold membership)
- Restaurant metadata (area, type)
- Product details (name, cuisine, price)

*Facts / Measures*
- Total orders
- Total delivered & cancelled orders
- Total sales amount
- Delivery duration
- Customer activity monthwise
- Delivery distance (computed from lat-long)
This enabled the creation of business KPIs used throughout the analysis.


3️⃣ **Exploratory Data Analysis (EDA)**

I started with fundamental business understanding:
✔ Customer insights
- Total distinct customers
- Age distribution (18–25, 26–30, etc.)
- Gold vs Non-gold members
- Year-over-year signups
- Customer distribution by area

✔ Restaurant insights
- Restaurant density by area
- Popular restaurant types

✔ Order insights
- Total & monthly orders
- Order cancellations
- Payment preferences
- Top dishes & cuisine analysis
- Month-wise average spending

This phase helped reveal customer behaviour, cuisine trends, and platform growth patterns.


4️⃣ **Deep-Dive Business Analysis**
- 🔹 A. Retention Analysis (Last 3 Months)
Used self-joins to measure month-over-month retention:

- 🔹 B. Churn Analysis
Calculated customers who did not return in the next month.

- 🔹 C. Customer Segmentation (Age Buckets)
- Grouped customers into age bins Then I calculated:
- Distribution of customers in each segment
% of total orders contributed by each age group

This revealed which age segments are highest drivers of revenue and order volume.

- 🔹 D. Cuisine & Product Analysis
- Top 5 ordered dishes
- Top 3 cuisines
- Average amount spent on top dishes
These insights determine product-level performance & menu strategy.


5️⃣ **Distance-Based Operational Analysis**
This was one of the most advanced part of this project.

✔ Calculated distance between restaurant & customer
- Using PostGIS function
- Converted lat-long to kilometers & computed:
- Average delivery distance
- Minimum & maximum reachable distance
- Delivery time vs. distance
- Order volume by distance bucket

✔ Analyzed:
- How many orders come from each bucket
- Average delivery time per distance group
- Performance drop-off for long-distance deliveries


**Final Business Insights and summary**
👥 Customer Insights
- 🔹 48% of all customers are between 40–60 years
- 🔹 Young users (18–40) have significantly lower presence & order contribution
- 🔹 User signups have been stagnant for 3 years
- 🔹 Signup count in 2025 dropped by 12% vs 2024
- 🔹 Q1–Q3 2025 new user signups remain flat
- 🔹 50% of the customers are Gold Members
- 🔹 Age group 40–60 contributes ~50% of total orders

💼 Business & Operations
- 🔹 10% of orders get cancelled
- 🔹 Cancellation rate decreased by ~2% each quarter in 2025
- 🔹 Order volume in Q1–Q3 2025 remains unchanged
- 🔹 Revenue in Q1–Q3 2025 is stagnant
- 🔹 UPI is the top payment method, while 24% use Food Wallet
- 🔹 Average retention (last 3 months): 12%
- 🔹 Average churn (last 3 months): 88%

🍽️ Cuisine & Order Behavior
- 🔹 Most ordered dish: Biriyani (15% of total orders)
- 🔹 Top cuisine: North Indian (34% of orders)
- 🔹 Average order value: ₹870 (consistent all months)
- 🔹 Average delivery time: 37 mins, Min: 15 mins, Max: 60 mins

🚚 Distance Insights
- 🔹 Average delivery distance: 3 km
- 🔹 70% of deliveries are within 4 km

**Summary:**
- Customer acquisition is stagnant, and younger audiences are not being captured, threatening long-term growth.
- Order volume and revenue are flat, showing that existing customers are not increasing their usage.
- High churn and low retention highlight an urgent need to improve customer experience and loyalty.

**To improve the Business the company has to focus on**
- Boosting new customer acquisition, especially among younger demographics.
- Improve retention through personalized offers, loyalty programs, and better engagement.
- Diversify the customer base to reduce reliance on the 40–60 age group.
- Enhance order experience to further reduce cancellations and improve satisfaction.
- Revitalize revenue growth by focusing on upselling, subscription models, and targeted promotions.
