SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[v_recruitheader](First_Name, Middle_Name, Last_Name, Address1, Address2, City, State, 
	Postal_Code, Home_Phone, Cell_Phone, EMail, Web_Page, ID)
AS 
SELECT  rec_firstname, 
	rec_middlename, 
	rec_lastname, 
	rec_address1, 
	rec_address2,
	rec_city = (select cty_name from city where cty_code = rec_city), 
	rec_state = (select cty_state from city where cty_code = rec_city), 
	rec_zip, 
	case len(rec_homephone)
	when 10 then '(' + left(rec_homephone, 3) + ') ' + substring(rec_homephone, 4,3) + '-' + substring(rec_homephone, 7,4) 
	else rec_homephone
	end, 
	case len(rec_cellphone)
	when 10 then '(' + left(rec_cellphone, 3) + ') ' + substring(rec_cellphone, 4,3) + '-' + substring(rec_cellphone, 7,4) 
	else rec_cellphone
	end, 
	rec_email, 
	rec_website, 
	rec_id
FROM recruitheader
GO
GRANT SELECT ON  [dbo].[v_recruitheader] TO [public]
GO
