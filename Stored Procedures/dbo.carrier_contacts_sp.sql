SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[carrier_contacts_sp]
	@carid				VARCHAR(8),
	@carname			VARCHAR(64),	
	@car_phone1			VARCHAR(10),
	@car_phone2			VARCHAR(10),
	@car_contact		VARCHAR(25),
	@car_phone3			VARCHAR(10),
	@car_email			VARCHAR(128) 
as

create table #temp1 (
	temp1_id 			INTEGER identity,
	trk_number 			INTEGER NULL,	
	trk_carrier 		VARCHAR(8) NULL,
	car_name			VARCHAR(64) NULL,
	car_address1		VARCHAR(64) NULL,
	car_address2		VARCHAR(64) NULL,
	car_phone1			VARCHAR(10) NULL,
	car_phone2			VARCHAR(10) NULL,
	car_contact			VARCHAR(25) NULL,
	cc_fname			VARCHAR(40) NULL,
	cc_lname			VARCHAR(40) NULL,
	car_phone3			VARCHAR(10) NULL,
	car_email			VARCHAR(128) NULL,
	)
-- Start PTS 87096 

DECLARE @IsCarrierContacts AS CHAR(1)

SELECT	@IsCarrierContacts = ISNULL(gi_string1, 'N')		
FROM	generalinfo
WHERE gi_name = 'CarrierMgmtSystem'

IF @IsCarrierContacts ='Y'
	BEGIN
--PTS 82374
	Update #temp1
	SET
	car_phone1 = CASE WHEN ISNULL(car_phone1,'') = '' THEN(SELECT Top 1 cc_phone1 FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y')ELSE car_phone1 END ,
	car_phone2 =CASE WHEN ISNULL(car_phone2,'') = '' THEN (SELECT Top 1 cc_phone2 FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE car_phone2 END,
	car_phone3 = CASE WHEN ISNULL(car_phone3,'') = '' THEN(SELECT Top 1 cc_cell FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y')ELSE car_phone3 END ,
	car_email =  CASE WHEN ISNULL(car_email,'') = '' THEN(SELECT Top 1 cc_email FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE car_email END,
	cc_lname = CASE WHEN ISNULL(cc_lname,'') = '' THEN (SELECT Top 1 cc_lname FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE cc_lname END,
	cc_fname = CASE WHEN ISNULL(cc_fname,'') = '' THEN (SELECT Top 1 cc_fname FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE cc_fname END
----PTS 53571 KMM/JJF 20100818 - DON'T RETURN RESULTS IF THERE IS ZERO CRITERIA
	END
ELSE
	BEGIN
	Update #temp1
	SET
	car_phone1 = CASE WHEN ISNULL(car_phone1,'') = '' THEN(SELECT Top 1 ce_phone1 FROM companyemail WHERE cmp_id = #temp1.trk_carrier and ce_defaultcontact = 'Y') ELSE car_phone1 END,
	car_phone2 = CASE WHEN ISNULL(car_phone2,'') = '' THEN (SELECT Top 1 ce_phone2 FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y') ELSE car_phone2 END,
	car_phone3 = CASE WHEN ISNULL(car_phone3,'') = '' THEN (SELECT Top 1 ce_mobilenumber FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y') ELSE car_phone3 END,
	car_email = CASE WHEN ISNULL(car_email,'') = '' THEN (SELECT Top 1 email_address FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y') ELSE car_email END,
	cc_lname = CASE WHEN ISNULL(cc_lname,'') = '' THEN (SELECT Top 1 contact_name FROM companyemail WHERE cmp_id =#temp1.trk_carrier  and ce_defaultcontact = 'Y') ELSE cc_lname END,
	cc_fname = CASE WHEN ISNULL(cc_fname,'') = '' THEN (SELECT Top 1 ce_fname FROM companyemail WHERE cmp_id =#temp1.trk_carrier  and ce_defaultcontact = 'Y') ELSE cc_fname END
	END
ENDPROC:
-- End PTS 87096 PR
SELECT ISNULL(trk_number,'') trk_number,        
       ISNULL(car_name,'') car_name,
       ISNULL(car_address1,'') car_address1,
       ISNULL(car_address2,'') car_address2,
       ISNULL(car_phone1,'') car_phone1,
       ISNULL(car_phone2,'') car_phone2,
       ISNULL(car_contact,'') car_contact,
	   ISNULL(cc_lname,'') cc_lname,
	   ISNULL(cc_fname,'') cc_fname,
       ISNULL(car_phone3,'') car_phone3,
       ISNULL(car_email,'') car_email    

  FROM #temp1	
 WHERE #temp1.trk_carrier IN (SELECT car_id 
                                FROM carrier WITH (NOLOCK) 
								--PTS 53571 KMM/JJF 20100818 add car_id unknown to return empty result message
                               WHERE car_status <> 'OUT' OR car_id = 'UNKNOWN')
	
GO
GRANT EXECUTE ON  [dbo].[carrier_contacts_sp] TO [public]
GO
