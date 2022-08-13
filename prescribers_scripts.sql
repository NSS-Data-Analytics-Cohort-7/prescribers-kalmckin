

SELECT *
FROM cbsa;

SELECT *
FROM drug;

SELECT *
FROM fips_county;

SELECT *
FROM overdoses;

SELECT *
FROM population;

SELECT *
FROM prescriber;

SELECT *
FROM prescription;

SELECT *
FROM zip_fips;

/* Q1 
a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims. */

SELECT npi, SUM(total_claim_count) AS claim_count
FROM prescription
    INNER JOIN prescriber
    USING (npi)
GROUP BY npi
ORDER BY claim_count desc;

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS claims_count
FROM prescription
    INNER JOIN prescriber
    USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY claims_count desc;

/* Q1_Answer
a. 1881634483; 99707
b. Bruce Pendley */

/* Q2 

a. Which specialty had the most total number of claims (totaled over all drugs)?

b. Which specialty had the most total number of claims for opioids?

c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? */

SELECT specialty_description, SUM(total_claim_count) AS claim_count
FROM prescriber
    INNER JOIN prescription
    USING (npi)
GROUP BY specialty_description
ORDER BY claim_count desc;

SELECT specialty_description, SUM(total_claim_count) AS claim_count
FROM prescriber
    INNER JOIN prescription
    USING (npi)
    INNER JOIN drug
    ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY claim_count desc;


/* Q2_Answer

a. Family Practice b. Nurse Practitioner c. d. */

/* Q3

a. Which drug (generic_name) had the highest total drug cost?

b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.*/


SELECT generic_name, SUM(total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
using (drug_name)
GROUP BY generic_name
order by total_cost desc;

SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS total_cost_per_day
FROM drug
INNER JOIN prescription
using (drug_name)
GROUP BY generic_name
order by total_cost_per_day desc;

/*Q3_Answer

a. "INSULIN GLARGINE,HUM.REC.ANLOG"  $,104,264,066.35
b. "C1 ESTERASE INHIBITOR"; $3,495.22 
*/

/* Q4 

a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.*/


SELECT drug_name,
CASE
    WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
    ELSE 'Neither'
END AS drug_type
FROM drug;

SELECT CAST(SUM(total_cost) as money), drug_type
FROM 
    (SELECT drug_name, prescription.total_drug_cost AS total_cost,
    CASE
    WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
    ELSE 'Neither'
    END AS drug_type
    FROM drug
    INNER JOIN prescription
    USING (drug_name)) AS sub
GROUP BY drug_type
ORDER BY SUM(total_cost) desc;



/* Q4_Answer
a. In code
b. Opioid "$105,080,626.37"; Antibiotic "$38,435,121.26"; */


/* Q5

a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population. */

