SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROCEDURE       [dbo].[inbound_view_drv_plan_brpt] 
	(@stringparm	varchar(255)
	)
AS

declare 
	@mmptype1       varchar(6),
	@leg_rev_mode	int,
	@mmptype2       varchar(254),
	@mmptype3       varchar(254),
	@mmptype4       varchar(254),
	@teamleader     varchar(254),
	@domicile       varchar(254),
	@fleet          varchar(254),
	@division       varchar(254),
	@company        varchar(254),
	@terminal       varchar(254),
	@states         varchar(254),
	@cmpids         varchar(254),
	@region1        varchar(254),
	@region2        varchar(254),
	@region3        varchar(254),
	@region4        varchar(254),
	@city           int,
	@hoursback      int,
	@hoursout       int,
	@days           int,
	@singledriver	varchar(8),
	@offset		int

-- PARSE STRING PARM
Select @mmptype1 = SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1)
SELECT @stringparm = SUBSTRING(@stringparm, PATINDEX('%,%', @stringparm) + 1, LEN(@stringparm))
Select @leg_rev_mode = CONVERT( int, @stringparm)


SELECT 	@mmptype2 = '',
	@mmptype3 = '',
	@mmptype4 = '',
	@teamleader = '',
	@domicile  = '',
	@fleet = '',
	@division = '',
	@company = '',
	@terminal = '',
	@states = '',
	@cmpids = '',
	@region1 = '',
	@region2 = '',
	@region3 = '',
	@region4 = '',
	@city = 0,
	@hoursback = 0,
	@hoursout = 0,
	@days = 0,
	@singledriver = 'UNKNOWN',
	@offset = 0

exec inbound_view_drv_plan2 @mmptype1, 	
	@mmptype2,
	@mmptype3,
	@mmptype4,
	@teamleader,
	@domicile,
	@fleet,
	@division,
	@company,
	@terminal,
	@states,
	@cmpids,
	@region1,
	@region2,
	@region3,
	@region4,
	@city,
	@hoursback,
	@hoursout,
	@days,
	@singledriver,
	@offset,
	@leg_rev_mode
GO
GRANT EXECUTE ON  [dbo].[inbound_view_drv_plan_brpt] TO [public]
GO
