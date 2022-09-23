SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_altaddressing_details]  @addresstype varchar(25)

AS
/********************************************************************************** 
   2/23/00 MZ: Used to fill the cboDetails() control for alternate addressing .
		Make sure that when adding new types, that it returns a single 
		column with either 
			1) just the value to be put into the altaddressing table
			2) the value to be put into the altaddressing table followed
			    by ' -- ' and the description.
		The calling program will check for --, if it exists will parse the
		characters up to the first double hyphen found and use that value.
		I know this is lame, but there is no identity column on manpowerprofile!!
   08/10/00 MZ Added RevType1 and RevType2 support 
   04/08/04 MZ Added ord_destregion1 support	
**********************************************************************************/

SET NOCOUNT ON 

IF @addresstype = 'mpp_id'
  BEGIN
	SELECT mpp_id + ' -- ' + CONVERT(varchar(25), ISNULL(mpp_lastname,'') + ', ' + ISNULL(mpp_firstname,'')) name
	INTO #temp
	FROM manpowerprofile
	WHERE mpp_status <> 'OUT'
	ORDER BY mpp_lastname, mpp_firstname, mpp_id
	
	DELETE #temp 
	WHERE name IS NULL

	SELECT name
	FROM #temp
  END

IF @addresstype = 'mpp_teamleader'
	SELECT desccode = CONVERT(VARCHAR(10), abbr) + ' -- ' + name
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = 'TeamLeader' 
	ORDER BY code

IF (@addresstype = 'ord_originregion1' OR @addresstype = 'ord_destregion1')
	SELECT rgh_id + ' -- ' + rgh_name name
	FROM regionheader (NOLOCK)
	WHERE rgh_type = 1 
	ORDER BY rgh_id

IF (@addresstype = 'ord_originregion2' OR @addresstype = 'ord_destregion2')
	SELECT rgh_id + ' -- ' + rgh_name name
	FROM regionheader (NOLOCK)
	WHERE rgh_type = 2 
	ORDER BY rgh_id

IF (@addresstype = 'ord_originregion3' OR @addresstype = 'ord_destregion3')
	SELECT rgh_id + ' -- ' + rgh_name name
	FROM regionheader (NOLOCK)
	WHERE rgh_type = 3 
	ORDER BY rgh_id

IF (@addresstype = 'ord_originregion4' OR @addresstype = 'ord_destregion4')
	SELECT rgh_id + ' -- ' + rgh_name name
	FROM regionheader (NOLOCK)
	WHERE rgh_type = 4 
	ORDER BY rgh_id

IF @addresstype = 'trc_number' 
	SELECT trc_number
	FROM tractorprofile (NOLOCK)
	WHERE trc_status <> 'OUT'
	ORDER BY trc_number

IF @addresstype = 'OrderRevType1'
	SELECT abbr
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = 'RevType1'
	ORDER BY abbr

IF @addresstype = 'OrderRevType2'
	SELECT abbr
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = 'RevType2'
	ORDER BY abbr

--VV25767 added OrderRevType3 and OrderRevType4
IF @addresstype = 'OrderRevType3'
	SELECT abbr
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = 'RevType3'
	ORDER BY abbr

IF @addresstype = 'OrderRevType4'
	SELECT abbr
	FROM labelfile (NOLOCK)
	WHERE labeldefinition = 'RevType4'
	ORDER BY abbr

IF @addresstype = 'None'
	SELECT ''

GO
GRANT EXECUTE ON  [dbo].[tmail_altaddressing_details] TO [public]
GO
