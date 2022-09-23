SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 38816 JJF 20080311 add parmlist
CREATE PROC [dbo].[d_loadtrc_sp] @trc varchar(8) , @number int, @parmlist varchar(254) AS
/**
 * 
 * NAME:
 * dbo.d_loadtrc_sp 
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
DECLARE @rowsecurity	char(1),
		@RowSecurityCustom char(1),
		@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS 42816 JJF 20080527
--PTS 53255 JJF 20101130
--DECLARE @tbl_trcrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--PTS 53255 JJF 20101130
DECLARE @tbl_trcrestrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loadtrc_custom_fn(@trc, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_trcrestrictedcustom
	SELECT * FROM  rowrestrict_tractor_fn(@trc, 'DropDownLookup1004', @parmlist)
END 


SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_trcrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_tractor_fn(@trc)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_tractorprofile_fn() 
	--END PTS 53255 JJF 20101130
END
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

if exists ( SELECT trc_number FROM tractorprofile WHERE trc_number LIKE @trc + '%' 
		AND (trc_status <> 'OUT' OR (trc_status = 'OUT' AND trc_retiredate >= @date))
		AND trc_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		AND	(	(@rowsecurity <> 'Y')
				OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
		--AND (EXISTS(select * FROM @tbl_trcrestrictedbyuser trcres WHERE tractorprofile.trc_number = trcres.value)
		--	OR @rowsecurity <> 'Y')
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_trcrestrictedcustom trcres WHERE tractorprofile.trc_number = trcres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	)
	SELECT trc_number
		FROM tractorprofile 
		WHERE trc_number LIKE @trc + '%' 
		AND (trc_status <> 'OUT' OR (trc_status = 'OUT' AND trc_retiredate >= @date))
		AND trc_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		AND	(	(@rowsecurity <> 'Y')
				OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
		--AND (EXISTS(select * FROM @tbl_trcrestrictedbyuser trcres WHERE tractorprofile.trc_number = trcres.value)
		--	OR @rowsecurity <> 'Y')
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_trcrestrictedcustom trcres WHERE tractorprofile.trc_number = trcres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	ORDER BY trc_number 
else 
	SELECT trc_number 
		FROM tractorprofile 
		WHERE trc_number = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadtrc_sp] TO [public]
GO
