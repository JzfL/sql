# Assignment 1: Design a Logical Model

## Question 1
Create a logical model for a small bookstore. 📚

At the minimum it should have employee, order, sales, customer, and book entities (tables). Determine sensible column and table design based on what you know about these concepts. Keep it simple, but work out sensible relationships to keep tables reasonably sized. Include a date table. There are several tools online you can use, I'd recommend [_Draw.io_](https://www.drawio.com/) or [_LucidChart_](https://www.lucidchart.com/pages/).

PNG uploaded under 02_assignments folder

## Question 2
We want to create employee shifts, splitting up the day into morning and evening. Add this to the ERD.

PNG uploaded under 02_assignments folder

## Question 3
The store wants to keep customer addresses. Propose two architectures for the CUSTOMER_ADDRESS table, one that will retain changes, and another that will overwrite. Which is type 1, which is type 2?

_Hint, search type 1 vs type 2 slowly changing dimensions._

Bonus: Are there privacy implications to this, why or why not?
```
Your answer...
```

Type 1 slowly changing dimensions overwites the existing value and does not retain history while type 2 slowly changing dimensions adds a new row for the new value and retains a history of past values. For CUSTOMER_ADDRESS table, if the store wishes to overwrite previous address, then it should use the UPDATE statement such as 
--UPDATE CUSTOMER_ADDRESS 
--SET customer_address='XXXXXX' 
--WHERE customer_id = 'XXXXXXX';

Or, if the store wishes to retain previous customer addresses, it should use the INSERT statement such as
--INSERT INTO CUSTOMER_ADDRESS (customer_id, address, date, ...)
--VALUES (xxxxxx, xxxxxxx, xxxxxx, ...);

For bonus qustion, yes, there is privacy implication to this. Typically sales records are kept for no more than 7 years in Canada, upon statute of limitation, records are supposed to be destroyed. Keeping personal records longer than that may impose breachments. Though, personal records can be kept longer than that if owner of infomation gave concent, so the historical addresses can be kept, but should ask for concent and keep both data entry methods available for both cases.

## Question 4
Review the AdventureWorks Schema [here](https://i.stack.imgur.com/LMu4W.gif)

Highlight at least two differences between it and your ERD. Would you change anything in yours?
```
Your answer...
```

First main difference is how the AdventureWorks schema was structured in a way that another layer was added in the schema that identified which group of tables are for which specific function. Where within one grouping, the interlinked keys are a lot more connected than those that are not. This could enable better understanding of the DB structure.

Secondly, there are independent tables that does not share keys with any other schemas or tables. dbo logs the system's performance and makes it easier for DB troubleshooting and upgrading.

# Criteria

[Assignment Rubric](./assignment_rubric.md)

# Submission Information

🚨 **Please review our [Assignment Submission Guide](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md)** 🚨 for detailed instructions on how to format, branch, and submit your work. Following these guidelines is crucial for your submissions to be evaluated correctly.

### Submission Parameters:
* Submission Due Date: `June 1, 2024`
* The branch name for your repo should be: `model-design`
* What to submit for this assignment:
    * This markdown (design_a_logical_model.md) should be populated.
    * Two Entity-Relationship Diagrams (preferably in a pdf, jpeg, png format).
* What the pull request link should look like for this assignment: `https://github.com/<your_github_username>/sql/pull/<pr_id>`
    * Open a private window in your browser. Copy and paste the link to your pull request into the address bar. Make sure you can see your pull request properly. This helps the technical facilitator and learning support staff review your submission easily.

Checklist:
- [X] Create a branch called `model-design`.
- [X] Ensure that the repository is public.
- [X] Review [the PR description guidelines](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md#guidelines-for-pull-request-descriptions) and adhere to them.
- [X] Verify that the link is accessible in a private browser window.

If you encounter any difficulties or have questions, please don't hesitate to reach out to our team via our Slack at `#cohort-3-help`. Our Technical Facilitators and Learning Support staff are here to help you navigate any challenges.
