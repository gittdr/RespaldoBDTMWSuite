SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROC [dbo].[d_loaddrvid_by_mpp_type_sp] @drv varchar(8) , @number int, 
												@parmlist varchar(254), 
												@mpp_typex varchar(20), 
												@mpp_type_value varchar(6) AS

set nocount on 

-- PTS 42913 JSwindell 10-2-2008 new proc created {copy of d_loaddrvid_sp}

DECLARE @daysout int, @date datetime

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1),
		@RowSecurityCustom char(1),
		@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS 42816 JJF 20080527
--PTS 53255 JJF 20101130
--DECLARE @tbl_drvrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130
DECLARE @tbl_drvrestrictedcustom TABLE(Value VARCHAR(8))

-- PTS 42913 <<START>>
CREATE TABLE #temp_w_mpp
(	mpp_lastfirst varchar(45) null, 
	mpp_id varchar(10) null, 
	mpp_otherid varchar(25) null,
	mpp_type1 varchar(6) null,
	mpp_type2 varchar(6) null,
	mpp_type3 varchar(6) null,
	mpp_type4 varchar(6) null,
	--PTS 64927 JJF 20130709
	mpp_address1 varchar(30),
	mpp_address2 varchar(30),
	cty_nmstct varchar(30),
	mpp_currentphone varchar(20) null
	--END PTS 64927 JJF 20130709
)
-- PTS 42913 <<END>>


SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loaddrvid_custom_fn(@drv, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_drvrestrictedcustom
	SELECT * FROM  rowrestrict_driver_fn(@drv, 'DropDownLookup1003', @parmlist)
END 


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

-- per the user, don't limit the rowcount  -- PTS 42913 
--if @number = 1 
--	set rowcount 1 
--else if @number <= 8 
--	set rowcount 8
--else if @number <= 16
--	set rowcount 16
--else if @number <= 24
--	set rowcount 24
--else
--	set rowcount 8

if exists ( SELECT mpp_id FROM manpowerprofile 
	WHERE mpp_id LIKE @drv + '%'
		AND (mpp_status <> 'OUT' OR (mpp_status = 'OUT' AND mpp_terminationdt >= @date))
		AND mpp_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	)


	--SELECT mpp_lastfirst , mpp_id, mpp_otherid,
		--PTS 64927 JJF 20130709
		Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4,
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp.mpp_lastfirst , mpp.mpp_id, mpp.mpp_otherid,
			mpp.mpp_type1, mpp.mpp_type2, mpp.mpp_type3, mpp.mpp_type4, 
			ISNULL(mpp.mpp_address1, '') as mpp_address1,
			ISNULL(mpp.mpp_address2, '') as mpp_address2,
			ISNULL(cty.cty_nmstct, '') as cty_nmstct,
			mpp.mpp_currentphone
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE mpp.mpp_id LIKE @drv + '%'
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	ORDER BY mpp_id 
Else
	--SELECT mpp_lastfirst , mpp_id, mpp_otherid,
	--PTS 64927 JJF 20130709
	Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4,
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4,
			'' as mpp_address1,
			'' as mpp_address2,
			'' as cty_nmstct,
			mpp_currentphone
		FROM manpowerprofile 
		WHERE mpp_id = 'UNKNOWN' 


IF @mpp_typex = 'mpp_type1' and @mpp_type_value is not null AND @mpp_type_value <> ''
Begin 
	-- remove previous data
	delete from #temp_w_mpp

	--PTS 64927 JJF 20130709
	Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4, 
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp.mpp_lastfirst , mpp.mpp_id, mpp.mpp_otherid,
			mpp.mpp_type1, mpp.mpp_type2, mpp.mpp_type3, mpp.mpp_type4, 
			ISNULL(mpp.mpp_address1, '') as mpp_address1,
			ISNULL(mpp.mpp_address2, '') as mpp_address2,
			ISNULL(cty.cty_nmstct, '') as cty_nmstct,
			mpp.mpp_currentphone
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE @mpp_type_value = mpp.mpp_type1
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'		
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')	
	ORDER BY mpp_id 

	IF @drv  <> 'UNKNOWN'
		begin
			delete from #temp_w_mpp
			where mpp_id NOT LIKE @drv + '%'
		end
End





IF @mpp_typex = 'mpp_type2' and @mpp_type_value is not null AND @mpp_type_value <> ''
-- IF @mpp_type2 is not null AND @mpp_type2 <> '' and @mpp_type_value is not null AND @mpp_type_value <> ''
Begin 
	-- remove previous data
	delete from #temp_w_mpp

	--PTS 64927 JJF 20130709
	Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4, 
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp.mpp_lastfirst , mpp.mpp_id, mpp.mpp_otherid,
			mpp.mpp_type1, mpp.mpp_type2, mpp.mpp_type3, mpp.mpp_type4,
			ISNULL(mpp.mpp_address1, '') as mpp_address1,
			ISNULL(mpp.mpp_address2, '') as mpp_address2,
			ISNULL(cty.cty_nmstct, '') as cty_nmstct,
			mpp.mpp_currentphone
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE @mpp_type_value = mpp.mpp_type2
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'		
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')	
	ORDER BY mpp_id 


	IF @drv  <> 'UNKNOWN'
		begin
			delete from #temp_w_mpp
			where mpp_id NOT LIKE @drv + '%'
		end
End



IF @mpp_typex = 'mpp_type3' and @mpp_type_value is not null AND @mpp_type_value <> ''
-- IF @mpp_type3 is not null AND @mpp_type3 <> '' and @mpp_type_value is not null AND @mpp_type_value <> ''
Begin 
	-- remove previous data
	delete from #temp_w_mpp

	--PTS 64927 JJF 20130709
	Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4,
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp.mpp_lastfirst , mpp.mpp_id, mpp.mpp_otherid,
			mpp.mpp_type1, mpp.mpp_type2, mpp.mpp_type3, mpp.mpp_type4,
			ISNULL(mpp.mpp_address1, '') as mpp_address1,
			ISNULL(mpp.mpp_address2, '') as mpp_address2,
			ISNULL(cty.cty_nmstct, '') as cty_nmstct,
			mpp.mpp_currentphone
		FROM	manpowerprofile mpp with (nolock)
		inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE @mpp_type_value = mpp.mpp_type3
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'		
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')	
	ORDER BY mpp_id 

	IF @drv  <> 'UNKNOWN'
		begin
			delete from #temp_w_mpp
			where mpp_id NOT LIKE @drv + '%'
		end
End

IF @mpp_typex = 'mpp_type4' and @mpp_type_value is not null AND @mpp_type_value <> ''
--IF @mpp_type4 is not null AND @mpp_type4 <> '' and @mpp_type_value is not null AND @mpp_type_value <> ''
Begin 
	-- remove previous data
	delete from #temp_w_mpp

	--PTS 64927 JJF 20130709
	Insert Into #temp_w_mpp (mpp_lastfirst , mpp_id, mpp_otherid,
			mpp_type1, mpp_type2, mpp_type3, mpp_type4,
			mpp_address1,
			mpp_address2,
			cty_nmstct,
			mpp_currentphone)
		Select  mpp.mpp_lastfirst , mpp.mpp_id, mpp.mpp_otherid,
			mpp.mpp_type1, mpp.mpp_type2, mpp.mpp_type3, mpp.mpp_type4,
			ISNULL(mpp.mpp_address1, '') as mpp_address1,
			ISNULL(mpp.mpp_address2, '') as mpp_address2,
			ISNULL(cty.cty_nmstct, '') as cty_nmstct,
			mpp.mpp_currentphone
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE @mpp_type_value = mpp.mpp_type4
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'		
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')	
	ORDER BY mpp_id 

	IF @drv  <> 'UNKNOWN'
		begin
			delete from #temp_w_mpp
			where mpp_id NOT LIKE @drv + '%'
		end
End

select mpp_lastfirst,  
	   cast(mpp_id as varchar(8)) 'mpp_id', 
		mpp_otherid, 
		mpp_type1, 
		mpp_type2, 
		mpp_type3, 
		mpp_type4,
		--PTS 64927 JJF 20130709
		mpp_address1,
		mpp_address2,
		cty_nmstct,
		mpp_currentphone
		--END PTS 64927 JJF 20130709
from #temp_w_mpp
union
select 'UNKNOWN', 'UNK', null, null, null, null, null, '', '', '', null

drop table #temp_w_mpp

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loaddrvid_by_mpp_type_sp] TO [public]
GO
