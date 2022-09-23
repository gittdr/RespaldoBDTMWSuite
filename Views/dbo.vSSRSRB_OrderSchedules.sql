SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create View [dbo].[vSSRSRB_OrderSchedules]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_OrderSchedules
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for OrderSchedules
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Revised 
 **/

Select  vSSRSRB_OrderInformation.*,
	[sch_number]  as [Schedule Number],
	[sch_description] as [Schedule Description],
	[ord_hdrnumber] as [Schedule Order Number],
	[sch_dow] as [Schedule Dow],
	[sch_dispatch] as [Schedule Dispatch] ,
	[sch_specificdate] as [Schedule Specific Date],
	[mpp_id] as [Schedule Driver ID],
	[trc_number] as [Schedule Tractor ID],
	[trl_id] as [Schedule Trailer ID]    ,
	[car_id] as [Schedule Carrier ID]    ,
	[sch_multisch] as [Schedule Multi Sched]     ,
	[sch_timeofday] as [Schedule TimeOfDay]  ,
	[mov_number] as [Schedule Move Number],
	[sch_scope]  as [Schedule Scope]   ,
	[sch_copies] as [Schedule Copies],
	[sch_copy_assetassignments] as [Schedule Copy AssetAssignments] ,
	[sch_copy_dates] as [Schedule Copy Dates] ,
	[sch_copy_rates] as [Schedule Copy Rates],
	[sch_copy_accessorials] as [Schedule Copy Accessorials],
	[sch_copy_notes] as [Schedule Copy Notes],
	[sch_copy_delinstructions] as [Schedule Copy Del Instructions],
	[sch_copy_paydetails] as [Schedule Copy PayDetails],
	[sch_copy_orderref] as [Schedule Copy Order Ref],
	[sch_copy_otherref] as [Schedule Other Ref],
	[sch_copy_frequency] as [Schedule Copy Frequency],
	[sch_expires_on] as [Schedule Expires On],
	[sch_minutestoadd] as [Schedule MinutesToAdd],
	[sch_lastrundate] as [Schedule Last Run Date],
	[sch_skip_holidays] as [Schedule Skip Holidays],
	[sch_skip_weekends] as [Schedule Weekends],
	[sch_firstrundate] as [Schedule First Run Date],
	[sch_hourstoadd] as [Schedule Hours To Add],
	[sch_timestorun] as [Schedule Times To Run],
	[sch_copy_loadreqs] as [Schedule Copy Load Requirements]     ,
	[lgh_number] as [Schedule Leg Header Number],
	[sch_weeks] as [Schedule Weeks],
	[sch_masterid] as [Schedule Master ID],
	[sch_rotationweek] as [Schedule Rotation Week],
	[mr_name] as [Schedule MR Name]
From    schedule_table WITH (NOLOCK)
	inner join  vSSRSRB_OrderInformation on schedule_table.[ord_hdrnumber] = [Order Header Number]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderSchedules] TO [public]
GO
