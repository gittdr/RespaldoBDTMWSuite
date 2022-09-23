SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[GetLicenseLimitForTrip]  @ps_trc varchar(8),@pl_lghnumber int
As
declare @v_FirstPUP int, @v_lastDRP int
declare @states table (state varchar(6))
/* look for first PUP and last DRP to only monitor license limit while loaded */
select @v_firstPUP = min(stp_mfh_sequence) from stops where lgh_number = @pl_lghnumber
and stp_type = 'PUP'
If @v_firstPUP is null select @v_firstPUP = min(stp_mfh_sequence) from stops where lgh_number = @pl_lghnumber

select @v_lastDRP = max(stp_mfh_sequence) from stops where lgh_number = @pl_lghnumber
and stp_type = 'DRP'
if @v_lastDRP is null select @v_lastDRP = max(stp_mfh_sequence) from stops where lgh_number = @pl_lghnumber

--select @ps_trc= '305013',@pl_lghnumber = 715371 --719099 -- 715371 690625

insert into @states 
select distinct sm_state 
from stops join statemiles on stp_lgh_mileage_mtid = statemiles.mt_identity
where stops.lgh_number = @pl_lghnumber

SELECT min(dbo.FleetLicense.fl_MaxGVW)   
    FROM dbo.FleetLicense join @states st on fl_Jurisdiction = state   
        WHERE ( dbo.FleetLicense.fl_FleetID = (select trc_fleet from tractorprofile where trc_number = @ps_trc ) )
          or (dbo.FleetLicense.trc_number = @ps_trc)
          and  dbo.FleetLicense.fl_ExpirationDate >= getdate() 
GO
GRANT EXECUTE ON  [dbo].[GetLicenseLimitForTrip] TO [public]
GO
