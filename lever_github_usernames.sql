#                   Git Usernames Per Candidate
# Purpose: 
# This query takes the weblinks provided by a candidate through Lever
# and returns their username and contact_id.  The username can be run
# through a repo analysis tool, and the result linked back to candidates 
# via the contact_id

# Find all weblinks that contain the string 'github'
WITH git AS(
    SELECT * 
    FROM `your-lever-project-here.ContactRestricted.contact_web_links`
    where url like  '%github%'
), 

# There are two major categories of strings that are returned 
# 1) github.io
# 2) github.com

# The username component of these urls are stored in different places,
# So we'll split them into two separate tables, `io` and `com`, 
# we will also be grabbing the username from the canonical_url via 
# string splitting 

io AS(
    SELECT contact_id, SPLIT(canonical_url, ".")[OFFSET(0)] as username
    FROM git 
    WHERE url LIKE "%github.io%"
), 

com AS(
    SELECT contact_id, 
           SPLIT(canonical_url, "/")[SAFE_OFFSET(1)] as username
    FROM git 
    WHERE url LIKE '%github.com/%' 
), 

# Join them back together 
contacts_and_usernames AS(
    SELECT DISTINCT * FROM(
    SELECT contact_id, LOWER(username) as username FROM com
    UNION ALL 
    SELECT contact_id, LOWER(username) AS username from  io
    )
    WHERE username NOT LIKE "%?%"
)

# count_usernames and multiple_usernames were for EDA
#count_usernames AS(
#    SELECT contact_id, count (username) as num_of_usernames
#    FROM contacts_and_usernames
#    GROUP BY contact_id
#), 

#multiple_usernames AS(
#    SELECT * 
#    FROM count_usernames 
#    WHERE num_of_usernames > 1
#)

SELECT * from contacts_and_usernames 
