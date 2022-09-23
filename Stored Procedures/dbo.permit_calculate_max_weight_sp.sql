SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permit_calculate_max_weight_sp] (@p_lgh_number int, @p_weight float OUTPUT)
AS
/**
 * 
 * NAME:
 * dbo.permit_calculate_max_weight_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This is the SQL 2000 version of the permit_calculate_max_weight_sp that 
 * calculates the max weight of a trip to be used during permit requirement generation
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * @p_weight float
 *
 * PARAMETERS:
 * 001 - @p_lgh_number, int, input
 *       This parameter indicates the leg number to gather dimensions information
 * 002 - @p_weight, float, output, null;
 *       This is the weight value to use when generating permit requirements
 *
 * 
 * REVISION HISTORY:
 * 03/06/2006 ? PTS31766 - Jason Bauwin ? original
 * 03/14/2008 - PTS41823 - Frank Michels - increased object in @weight table to varchar(21) to prevent truncation errors
 *
 **/
declare @v_trc varchar (8), @v_trl varchar(13), @v_trl2 varchar(13)

declare @weight table (object varchar(21),
							  weight  float NULL)


select @v_trc = lgh_tractor,
       @v_trl = lgh_primary_trailer,
       @v_trl2 = lgh_primary_pup
  from legheader
 where lgh_number = @p_lgh_number

insert into @weight (object, weight)
select 'TRC', trc_tareweight
  from tractorprofile
 where trc_number = @v_trc

insert into @weight (object, weight)
select 'TRL', trl_tareweight 
  from trailerprofile
 where trl_id = @v_trl

insert into @weight (object, weight)
select 'TRL2', trl_tareweight 
  from trailerprofile
 where trl_id = @v_trl2

--factor in weight of commodity, first take from the frightdetail if that is not present take from the commodity profile
--factor in weight of commodity, first take from the frightdetail if that is not present take from the commodity profile
insert into @weight (object, weight)
select 'Trip Cmd - ' + freightdetail.cmd_code, sum(freightdetail.fgt_weight)
  from freightdetail
  join stops on stops.stp_number = freightdetail.stp_number
 where freightdetail.cmd_code <> 'UNKNOWN'
   and stops.lgh_number = @p_lgh_number
   and stops.stp_type = 'DRP'
 group by freightdetail.cmd_code

update @weight
   set object = 'Master Cmd - ' + cmd_code, weight = commodity.cmd_default_weight
  from commodity
 where object = 'Trip Cmd - ' + commodity.cmd_code
   and isnull(weight,0) = 0


select @p_weight = sum(isnull(weight,0))
  from @weight

GO
GRANT EXECUTE ON  [dbo].[permit_calculate_max_weight_sp] TO [public]
GO
