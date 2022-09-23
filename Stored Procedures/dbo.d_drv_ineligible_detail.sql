SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_drv_ineligible_detail] @entrydate datetime, @terminal varchar(6), @dih_id integer
as  

/*
*	PTS 43873 - DJM - This is basically a report displaying the Minimum Pay status by Driver.
*/

Declare @detail Table(
	did_id	int		null,
	dih_id	int		null,
	mpp_id				varchar(12)		null,
	did_reason			varchar(6)		null,
	did_terminal		varchar(6)		null,
	did_createby		varchar(255)	null,
	did_createdate		datetime		null,
	did_lastupdateby	varchar(255)	null,
	did_lastupdatedt	datetime		null,
	mpp_lastfirst		varchar(100)	null,
	mpp_firstname		varchar(40)		null,
	mpp_middlename		varchar(40)		null,
	mpp_lastname		varchar(40)		null)

-- Retrieve rows for any existing Header/Detail combinations.
Insert into @detail
SELECT di_detail.did_id,   
     di_detail.dih_id,   
     manpowerprofile.mpp_id,
     di_detail.did_reason,   
     manpowerprofile.mpp_terminal did_terminal,   
     di_detail.did_createby,   
     di_detail.did_createdt,   
     di_detail.did_lastupdateby,   
     di_detail.did_lastupdatedt,
	manpowerprofile.mpp_lastfirst,
	isNull(manpowerprofile.mpp_firstname,'') mpp_firstname,
	isNull(manpowerprofile.mpp_middlename,'') mpp_middlename,
	isNull(manpowerprofile.mpp_lastname, '') mpp_lastname
FROM di_detail JOIN manpowerprofile ON di_detail.mpp_id = manpowerprofile.mpp_id
		join di_header on di_detail.dih_id = di_header.dih_id 
Where manpowerprofile.mpp_actg_type = 'P'
	and manpowerprofile.mpp_terminal = di_header.dih_terminal
	and di_header.dih_id = @dih_id
	and di_header.dih_terminal = @terminal
	and di_header.dih_date = @entrydate

-- Insert rows for any Drivers not already recorded in the Detail for the Terminal/Date.
Insert into @detail
select 0,
	(select isNull(dih_id,0) dih_id from di_header where dih_id = @dih_id or (dih_terminal = @terminal and dih_date = @entrydate)),
	manpowerprofile.mpp_id,
	'UNK',
	manpowerprofile.mpp_terminal did_terminal,   
	null,
	null,
	null,
	null,
	manpowerprofile.mpp_lastfirst,
	isNull(manpowerprofile.mpp_firstname,'') mpp_firstname,
	isNull(manpowerprofile.mpp_middlename,'') mpp_middlename,
	isNull(manpowerprofile.mpp_lastname, '') mpp_lastname
from manpowerprofile
where manpowerprofile.mpp_terminal = @terminal
	and manpowerprofile.mpp_actg_type = 'P'
	and not exists(select 1 from di_detail join di_header on di_detail.dih_id = di_header.dih_id
					where di_detail.mpp_id = manpowerprofile.mpp_id 
						and di_header.dih_date = @entrydate 
						and di_header.dih_terminal = manpowerprofile.mpp_terminal)



-- Insert rows for an existing Header record and any Drivers not already recorded in the Detail for the Terminal/Date.
--Insert into @detail
--select 0,
--	0,
--	manpowerprofile.mpp_id,
--	'UNK',
--	manpowerprofile.mpp_terminal did_terminal,   
--	null,
--	null,
--	null,
--	null,
--	manpowerprofile.mpp_lastfirst,
--	isNull(manpowerprofile.mpp_firstname,'') mpp_firstname,
--	isNull(manpowerprofile.mpp_middlename,'') mpp_middlename,
--	isNull(manpowerprofile.mpp_lastname, '') mpp_lastname
--from manpowerprofile
--where manpowerprofile.mpp_terminal = @terminal
--	and manpowerprofile.mpp_actg_type = 'P'
--	and not exists(select 1 from di_detail join di_header on di_detail.dih_id = di_header.dih_id
--					where di_detail.mpp_id = manpowerprofile.mpp_id 
--						and di_header.dih_date = @entrydate 
--						and di_header.dih_terminal = manpowerprofile.mpp_terminal)
--




Select * from @detail

GO
GRANT EXECUTE ON  [dbo].[d_drv_ineligible_detail] TO [public]
GO
