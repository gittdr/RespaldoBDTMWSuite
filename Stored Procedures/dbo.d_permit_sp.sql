SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_permit_sp] @PM_Name varchar(50)
As
/**
 * 
 * NAME: d_permit_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns all columns on the permit master table for a given permit master
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @PM_Name, varchar(50), input
 *       This parameter indicates the name of the permit master to get information on
 * REFERENCES:
 * None
 * 
 * REVISION HISTORY:
 * 08/26/2005 - PTS29495 - Jason Bauwin - Added two max 50 character comment fields
 *
 **/


	SELECT    PM_ID, 
	          PIA_ID, 
	          PM_Name, 
	          PM_Type, 
	          PM_Permit_Cost, 
	          PM_Contact, 
	          PM_Contact_Phone, 
	          PM_Contact_Fax, 
	          PM_Contact_Email,
	          PM_Contact2, 
	          PM_Contact2_Phone, 
	          PM_Contact2_Fax, 
	          PM_Contact2_Email,
	          PM_Comment1,
	          PM_Comment2
	FROM     Permit_Master
	WHERE    PM_Name = @PM_Name

GO
GRANT EXECUTE ON  [dbo].[d_permit_sp] TO [public]
GO
