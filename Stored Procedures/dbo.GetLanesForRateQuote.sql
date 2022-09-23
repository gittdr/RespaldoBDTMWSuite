SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetLanesForRateQuote]
	@Branch varchar(12),
	@BillTo varchar(8),
	@EquipmentType varchar(6),
	@FreightClass varchar(6),
	@Weight int,
	@OriginCompany varchar(8),
	@OriginCity int,
	@OriginZip varchar(10),
	@OriginCounty varchar(10),
	@OriginState varchar(10),
	@OriginCountry varchar(10),
	@DestinationCompany varchar(8),
	@DestinationCity int,
	@DestinationZip varchar(10),
	@DestinationCounty varchar(10),
	@DestinationState varchar(10),
	@DestinationCountry varchar(10)
as

DECLARE @matchData TABLE
(	[RowId] [bigint] NULL,
	[laneid] [int] NOT NULL,
	[lanecode] [varchar](15) NOT NULL,
	[OriginTypeId] [int] NULL,
	[OriginType] [varchar](7) NOT NULL,
	[OriginValue] [varchar](50) NULL,
	[DestinationTypeId] [int] NULL,
	[DestinationType] [varchar](7) NOT NULL,
	[DestinationValue] [varchar](50) NULL
) 


insert @matchData
select row_number() over(order by core_lane.laneid) as RowId, core_lane.laneid,core_lane.lanecode, 
	org.type as OriginTypeId,
	case when org.type = 1 then 'Company'
		when org.type = 2 then 'City'
		when org.type = 3 then 'Zip'
		when org.type = 4 then 'County'
		when org.type = 5 then 'State'
		when org.type = 6 then 'Country'
		when org.type = 7 then 'ZipRegion'
		else 'Other' end as OriginType,
	case when org.type = 1 then org.companyid
		when org.type = 2 then org.cityname
		when org.type = 3 then org.zippart
		when org.type = 4 then org.county
		when org.type = 5 then org.stateabbr
		when org.type = 6 then org.countrycode
		when org.type = 7 then (select RegionName from core_laneregion where core_laneregion.RegionId = org.RegionId)
		else '' end as OriginValue,
	dest.type as DestinationTypeId,
	case when Dest.type = 1 then 'Company'
		when Dest.type = 2 then 'City'
		when Dest.type = 3 then 'Zip'
		when Dest.type = 4 then 'County'
		when Dest.type = 5 then 'State'
		when Dest.type = 6 then 'Country'
		when Dest.type = 7 then 'ZipRegion'
		else 'Other' end as DestinationType,
	case when Dest.type = 1 then Dest.companyid
		when Dest.type = 2 then Dest.cityname
		when Dest.type = 3 then Dest.zippart
		when Dest.type = 4 then Dest.county
		when Dest.type = 5 then Dest.stateabbr
		when Dest.type = 6 then Dest.countrycode
		when Dest.type = 7 then (select RegionName from core_laneregion where core_laneregion.RegionId = Dest.RegionId)
		else '' end as DestinationValue
	from core_lane join core_lanelocation as org on org.laneid = core_lane.laneid
				join core_lanelocation as dest on org.laneid = dest.laneid and org.IsOrigin = 1 and dest.IsOrigin = 2
where ((org.type = 1 and org.companyid = @OriginCompany) or
		(org.type = 2 and org.citycode= @OriginCity) or
		(org.type = 3 and org.zippart = substring(@OriginZip,1,DataLength(org.zippart))) or
		(org.type = 4 and org.county= @OriginCounty) or
		(org.type = 5 and org.stateabbr= @OriginState) or
		(org.type = 6 and substring(org.countrycode,1,1) = substring(@OriginCountry,1,1)) or
		(org.type = 7 and exists (select RegionId from core_laneregiondetail d
									where d.RegionId = org.RegionId and
											d.zippart = substring(@OriginZip,1,DataLength(d.zippart)))))
and
		((Dest.type = 1 and Dest.companyid = @DestinationCompany) or
		(Dest.type = 2 and Dest.citycode= @DestinationCity) or
		(Dest.type = 3 and Dest.zippart = substring(@DestinationZip,1,DataLength(Dest.zippart))) or
		(Dest.type = 4 and Dest.county= @DestinationCounty) or
		(Dest.type = 5 and Dest.stateabbr= @DestinationState) or
		(Dest.type = 6 and substring(Dest.countrycode,1,1) = substring(@DestinationCountry,1,1))  or
		(Dest.type = 7 and exists (select RegionId from core_laneregiondetail d
									where d.RegionId = Dest.RegionId and
											d.zippart = substring(@DestinationZip,1,DataLength(d.zippart)))))
select core_lane.laneid,
		core_lane.lanecode,
		core_lane.lanename,
		m1.OriginTypeId,
		m1.OriginType,
		m1.OriginValue,
		m1.DestinationTypeId,
		m1.DestinationType,
		m1.DestinationValue
		  from @matchData as m1 join core_lane on core_lane.laneid = m1.laneid
where RowId in (select min(RowId) from @matchData as m2
				where m1.laneid = m2.laneid)
GO
GRANT EXECUTE ON  [dbo].[GetLanesForRateQuote] TO [public]
GO
