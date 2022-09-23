SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE 	PROCEDURE [dbo].[contactlist_sp]
	@cmp_id		varchar(8) = NULL

AS

/**
 * 
 * NAME:
 * contactlist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns list of contacts for a company or a carrier which seem to be in the same table using the cmp_id field for the 
 * company or carrier ID.
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: contact information for a particular company or carrier
 *
 * PARAMETERS:
 * @cmp_id	varchar(8)	Company ID or carrier ID
 *
 *
 * REVISION HISTORY:
 * 10/6/2007.01 ? PTS32196 DPETE 
 *
 **/

--PTS 48753 JJF 20090825
--Add a branch for CarrierMgmtSystem GI setting
IF NOT EXISTS(	SELECT	gi_name
				FROM	dbo.generalinfo
				WHERE	gi_name = 'CarrierMgmtSystem'
						AND gi_string1 = 'Y'
		) BEGIN	
	
--END PTS 48753 JJF 20090825
	If not exists (select 1 from companyemail where cmp_id = @cmp_id and type = 'S' and ce_source = 'CAR')
	select ' ' contact_name
	,'' ce_phone1
	,'' ce_phone1_ext
	,'' ce_phone2
	,'' ce_phone2_ext
	,'' ce_mobilenumber
	,'' ce_faxnumber
	,'' email_address
	,'' ce_title



	else
	select contact_name
	,isnull(ce_phone1,'') ce_phone1
	,isnull(ce_phone1_ext,'') ce_phone1_ext
	,isnull(ce_phone2,'') ce_phone2
	,isnull(ce_phone2_ext,'') ce_phone2_ext
	,isnull(ce_mobilenumber,'') ce_mobilenumber
	,isnull(ce_faxnumber,'') ce_faxnumber
	,isnull(email_address,'') email_address
	,isnull(ce_title,'') ce_title
	from companyemail
	where cmp_id = @cmp_id and type = 'S' and ce_source = 'CAR'
	order by Case ce_defaultcontact when 'y' then '    ' else contact_name end
END
--PTS 48753 JJF 20090825
ELSE BEGIN
	IF NOT EXISTS(	SELECT 1 
					FROM	carriercontacts
					WHERE	car_id = @cmp_id
							AND ISNULL(cc_retired, 'N') = 'N') BEGIN
		SELECT	' ' AS contact_name,
				'' AS ce_phone1,
				'' AS ce_phone1_ext,
				'' AS ce_phone2,
				'' AS ce_phone2_ext,
				'' AS ce_mobilenumber,
				'' AS ce_faxnumber,
				'' AS email_address,
				'' AS ce_title
	END
	ELSE BEGIN
		SELECT	coalesce(cc_fname + ' ', '') + coalesce(cc_lname, '') as contact_name,
				isnull(cc_phone1,'') as ce_phone1,
				ISNULL(cc_phone1_ext,'') as ce_phone1_ext,
				ISNULL(cc_phone2, '') as ce_phone2,
				ISNULL(cc_phone2_ext, '') as ce_phone2_ext,
				ISNULL(cc_cell, '') as ce_mobilenumber,
				ISNULL(cc_fax, '') as ce_faxnumber,
				ISNULL(cc_email, '') as email_address,
				ISNULL(cc_title, '') as ce_title
		FROM	carriercontacts
		WHERE	car_id = @cmp_id
				AND ISNULL(cc_retired, 'N') = 'N'
		ORDER BY	CASE cc_default_carrier_addr 
						WHEN 'Y' THEN '   ' 
						ELSE coalesce(cc_fname + ' ', '') + coalesce(cc_lname, '')	
					END
	END
END
--END PTS 48753 JJF 20090825

RETURN 0
GO
GRANT EXECUTE ON  [dbo].[contactlist_sp] TO [public]
GO
