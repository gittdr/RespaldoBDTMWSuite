SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadapdrvid_sp] @drv varchar(8) , @number int AS

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
--DECLARE @tbl_drvrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_drvrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_driver_fn(@emp)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_manpowerprofile_fn() 
	--PTS 53255 JJF 20101130
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

if exists ( SELECT mpp_id 
			FROM manpowerprofile 
			WHERE mpp_id LIKE @drv + '%' AND mpp_actg_type = 'A'
				AND ((mpp_status <> 'OUT' OR (mpp_status = 'OUT' AND mpp_terminationdt >= @date)))
				--PTS 42816 JJF 20080527
				--PTS 53255 JJF 20101130
				--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
				--	OR @rowsecurity <> 'Y')
				AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
				--END PTS 53255 JJF 20101130
				--END PTS 42816 JJF 20080527
			)
	SELECT mpp_lastfirst , mpp_id, mpp_otherid 
		FROM manpowerprofile 
		WHERE mpp_id LIKE @drv + '%' AND 
			  mpp_actg_type = 'A' AND
			 (mpp_status <> 'OUT' OR (mpp_status = 'OUT' AND  mpp_terminationdt >= @date))
				--PTS 42816 JJF 20080527
				--PTS 53255 JJF 20101130
				--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
				--	OR @rowsecurity <> 'Y')
				AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
				--END PTS 53255 JJF 20101130
				--END PTS 42816 JJF 20080527
	ORDER BY mpp_id 
Else
	SELECT mpp_lastfirst , mpp_id, mpp_otherid   
		FROM manpowerprofile 
		WHERE mpp_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadapdrvid_sp] TO [public]
GO
