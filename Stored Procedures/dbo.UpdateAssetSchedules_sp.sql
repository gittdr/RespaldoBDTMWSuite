SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateAssetSchedules_sp] (@AssetType int = 0, @payScheduleUpdated bit = 0) as
/**
*
* NAME:
* dbo.UpdateAssetSchedules_sp
*
* TYPE:
* Procedure
*
* DESCRIPTION:
* Updates PaysceduleID for all assets of a type, or all assets
*
* RETURNS:
*
* RESULT SETS:
*
* PARAMETERS:
AssetType is a numeric value
	1	DRV
	2	CAR
	3	TRC
	4	TRL
	5	PTO
	6	TPY
	0	All asset types

* Sample Execution:

UpdateAssetSchedules_sp

UpdateAssetSchedules_sp 1

UpdateAssetSchedules_sp 2

UpdateAssetSchedules_sp 3

UpdateAssetSchedules_sp 4

UpdateAssetSchedules_sp 5

UpdateAssetSchedules_sp 6

* History
* 2014/11/10 | PTS 83554 | vjh pay schedule based retrieval
* 2014/12/05 | PTS 85028 | Dave Shirey better handle payschedule updates
* 2014/12/10 | PTS 83554 | vjh better handle settle by payto
* 2015/01/29 | PTS 83554 | vjh Third Party should use ThirdPartyType1-4

**/

Begin
  set NOCOUNT ON

  -- updating payto requires updating all assets that have an assigned payto
  
  if @AssetType in (0, 1, 5)
  begin
    -- update driver pay schedule id with matching driver pay schedule unless asset has an assigned payto then set it to the matching payto's pay schedule id
    update dr
    set dr.PayScheduleId =     
      case 
        when pt.pto_id is not NULL and pt.pto_stlByPayTo = 1
	      then dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
	    else dbo.fn_GetPayScheduleId( 1, dr.mpp_actg_type, dr.mpp_company, dr.mpp_division, dr.mpp_terminal, dr.mpp_fleet, dr.mpp_type1, dr.mpp_type2, dr.mpp_type3, dr.mpp_type4, case when isnull(ms.AutoCloseStatus, 'DIS') = 'DIS' then 0 else 1 end)
	  end
    from dbo.manpowerprofile dr left outer join dbo.ManpowerProfile_moreSettings ms
      on dr.mpp_id = ms.resource_id
      left outer join dbo.payto pt
      on dr.mpp_payto = pt.pto_id and pt.pto_id != 'UNKNOWN'
    where dr.mpp_actg_type <> 'N' 
      and dr.mpp_id = case when (@payScheduleUpdated = 0 and dr.PayScheduleId is null) or @payScheduleUpdated = 1 then dr.mpp_id else '' end
  end
  
  if @AssetType in (0, 2, 5)
  begin
    -- update carrier pay schedule id with matching carrier pay schedule unless asset has an assigned payto then set it to the matching payto's pay schedule id
    update cr
    set cr.PayScheduleId = 
      case 
        when pt.pto_id is not NULL and pt.pto_stlByPayTo = 1
	      then dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
        else dbo.fn_GetPayScheduleId( 2, cr.car_actg_type, 'UNK', 'UNK', 'UNK', 'UNK', cr.car_type1, cr.car_type2, cr.car_type3, cr.car_type4, case when isnull(ms.AutoCloseStatus, 'DIS') = 'DIS' then 0 else 1 end)
      end
    from carrier cr left outer join dbo.carrier_moreSettings ms
      on cr.car_id = ms.resource_id
      left outer join dbo.payto pt
      on cr.pto_id = pt.pto_id and pt.pto_id != 'UNKNOWN'
    where cr.car_actg_type <> 'N'
      and cr.car_id = case when (@payScheduleUpdated = 0 and cr.PayScheduleId is null) or @payScheduleUpdated = 1 then cr.car_id else '' end
  end
  
  if @AssetType in (0, 3, 5)
  begin
    -- update tractor pay schedule id with matching tractor pay schedule unless asset has an assigned payto then set it to the matching payto's pay schedule id
    update tr
    set tr.PayScheduleId = 
      case 
        when pt.pto_id is not NULL and pt.pto_stlByPayTo = 1
	      then dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
        else dbo.fn_GetPayScheduleId( 3, tr.trc_actg_type, tr.trc_company, tr.trc_division, tr.trc_terminal, tr.trc_fleet, tr.trc_type1, tr.trc_type2, tr.trc_type3, tr.trc_type4, case when isnull(ms.AutoCloseStatus, 'DIS') = 'DIS' then 0 else 1 end)
      end
    from tractorprofile tr left outer join dbo.tractorprofile_moreSettings ms
      on tr.trc_number = ms.resource_id
      left outer join dbo.payto pt
      on tr.trc_owner = pt.pto_id and pt.pto_id != 'UNKNOWN'
    where tr.trc_actg_type <> 'N'
      and tr.trc_number = case when (@payScheduleUpdated = 0 and tr.PayScheduleId is null) or @payScheduleUpdated = 1 then tr.trc_number else '' end
  end
  
  if @AssetType in (0, 4, 5)
  begin
    -- update trailer pay schedule id with matching trailer pay schedule unless asset has an assigned payto then set it to the matching payto's pay schedule id
    update tl
    set tl.PayScheduleId = 
      case 
        when pt.pto_id is not NULL and pt.pto_stlByPayTo = 1
	      then dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
        else dbo.fn_GetPayScheduleId( 4, tl.trl_actg_type, tl.trl_company, tl.trl_division, tl.trl_terminal, tl.trl_fleet, tl.trl_type1, tl.trl_type2, tl.trl_type3, tl.trl_type4, 0)
      end
    from trailerprofile tl left outer join dbo.payto pt
      on tl.trl_owner = pt.pto_id and pt.pto_id != 'UNKNOWN'
    where tl.trl_actg_type <> 'N'
      and tl.trl_id = case when (@payScheduleUpdated = 0 and tl.PayScheduleId is null) or @payScheduleUpdated = 1 then tl.trl_id else '' end
  end
  
  if @AssetType in (0, 5)
  begin
    update pt
    set pt.PayScheduleId = dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
    from payto pt
    where pt.PayScheduleId is null
      and pt.pto_id = case when (@payScheduleUpdated = 0 and pt.PayScheduleId is null) or @payScheduleUpdated = 1 then pt.pto_id else '' end
  end
  
  
  if @AssetType in (0, 5, 6)
  begin
    -- update third party pay schedule id with matching third party pay schedule unless asset has an assigned payto then set it to the matching payto's pay schedule id
    update tp
    set tp.PayScheduleId = 
      case 
        when pt.pto_id is not NULL and pt.pto_stlByPayTo = 1
	      then dbo.fn_GetPayScheduleId( 5, 'A', pt.pto_company, pt.pto_division, pt.pto_terminal, pt.pto_fleet, pt.pto_type1, pt.pto_type2, pt.pto_type3, pt.pto_type4, 0)
        else dbo.fn_GetPayScheduleId( 6, tp.tpr_actg_type, 'UNK', 'UNK', 'UNK', 'UNK', tp.ThirdPartyType1, tp.ThirdPartyType2, tp.ThirdPartyType3, tp.ThirdPartyType4, 0)
      end
    from thirdpartyprofile tp  left outer join dbo.payto pt
      on tp.tpr_payto = pt.pto_id and pt.pto_id != 'UNKNOWN'
    where tp.tpr_actg_type <> 'N'
      and tp.tpr_id = case when (@payScheduleUpdated = 0 and tp.PayScheduleId is null) or @payScheduleUpdated = 1 then tp.tpr_id else '' end
  end

End

GO
GRANT EXECUTE ON  [dbo].[UpdateAssetSchedules_sp] TO [public]
GO
