SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loaddrv_sp] @drv varchar(40) , @number int AS
/**
 * 
 * NAME:
 * dbo.d_loaddrv_sp 
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
DECLARE @v_string1 char(1), @v_string2 char(1), @v_string3 char(1), @v_string4 char(1)
select	@v_string1 = isnull(gi_string1,'N'),
		@v_string2 = isnull(gi_string2,'N'),
		@v_string3 = isnull(gi_string3,'N'),
		@v_string4 = isnull(gi_string4,'N')
from generalinfo where gi_name = 'driverdropdowncontrol'

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

if exists ( SELECT mpp_lastfirst FROM manpowerprofile 
		WHERE mpp_lastfirst LIKE @drv + '%' 
			AND (mpp_status <> 'OUT' OR (mpp_status = 'OUT' AND 
				mpp_terminationdt >= @date))
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
	BEGIN
	SELECT mpp.mpp_lastfirst, 
		mpp.mpp_id,
		--PTS 64927 JJF 20130709
		ISNULL(mpp.mpp_address1, '') as mpp_address1,
		ISNULL(mpp.mpp_address2, '') as mpp_address2,
		ISNULL(cty.cty_nmstct, '') as cty_nmstct,
		mpp.mpp_currentphone,
		mpp.mpp_type1,
		mpp.mpp_type2,
		mpp.mpp_type3,
		mpp.mpp_type4,
		--Left this last drivertypes column in, although I didn't find any usages for it...
		--END PTS 64927 JJF 20130709
		rtrim(
			case @v_string1 when 'Y' then mpp_type1 + ' ' else '' end + 
			case @v_string2 when 'Y' then mpp_type2 + ' ' else '' end + 
			case @v_string3 when 'Y' then mpp_type3 + ' ' else '' end + 
			case @v_string4 when 'Y' then mpp_type4 else '' end
		) 'drivertypes'
	INTO #drv
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE mpp.mpp_lastfirst LIKE @drv + '%' 
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))	
			--PTS 42816 JJF 20080527
			--PTS 53255 JJF 20101130
			--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
			--	OR @rowsecurity <> 'Y')
			AND	(	(@rowsecurity <> 'Y')
				OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 53255 JJF 20101130
			--END PTS 42816 JJF 20080527
	SELECT * 
	FROM #drv
	ORDER BY mpp_lastfirst 
	END
else 
	SELECT mpp.mpp_lastfirst, 
		mpp.mpp_id, 
		--PTS 64927 JJF 20130709
		'' as mpp_address1,
		'' as mpp_address2,
		'' as cty_nmstct,
		mpp.mpp_currentphone,
		mpp.mpp_type1,
		mpp.mpp_type2,
		mpp.mpp_type3,
		mpp.mpp_type4,
		--END PTS 64927 JJF 20130709
		'' as drivertypes
		FROM	manpowerprofile mpp with (nolock)
		WHERE mpp_lastfirst = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loaddrv_sp] TO [public]
GO
