SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadtrl_dolly_sp] @trl varchar(13) , @number int AS
/**
 * 
 * NAME:
 * dbo.d_loadtrl_dolly_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


DECLARE @daysout int, @date datetime

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

SELECT @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT @daysout = gi_integer1, 
		 @date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE'
If @daysout <> 999 
	SELECT @date = dateadd (day, @daysout, getdate())

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_trlrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_trlrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_trailer_fn(@trL)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_trailerprofile_fn() 
	--END PTS 53255 JJF 20101130
END
--END PTS 42816 JJF 20080527

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT trl_id FROM trailerprofile WHERE trl_id LIKE @trl + '%' 
	AND (trl_status <> 'OUT' OR (trl_status = 'OUT' AND trl_retiredate >= @date))
	and trl_equipmenttype = 'DOLLY'
	and trl_status <> 'END'
	--PTS 42816 JJF 20080527
	--PTS 53255 JJF 20101130
	--AND (EXISTS(select * FROM @tbl_trlrestrictedbyuser trlres WHERE trailerprofile.trl_number = trlres.value)
	--	OR @rowsecurity <> 'Y')
	AND	(	(@rowsecurity <> 'Y')
		OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	)
	--END PTS 53255 JJF 20101130
	--END PTS 42816 JJF 20080527
	) 
	SELECT trl_id 
		FROM trailerprofile 
		WHERE trl_id LIKE @trl + '%' 
		AND (trl_status <> 'OUT' OR (trl_status = 'OUT' AND trl_retiredate >= @date))
		and trl_equipmenttype = 'DOLLY'
		AND trl_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_trlrestrictedbyuser trlres WHERE trailerprofile.trl_number = trlres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		--END PTS 42816 JJF 20080527
	ORDER BY trl_id
else 
	SELECT trl_id 
		FROM trailerprofile 
		WHERE trl_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadtrl_dolly_sp] TO [public]
GO
