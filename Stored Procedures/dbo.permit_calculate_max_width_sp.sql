SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permit_calculate_max_width_sp] (@p_lgh_number int, @p_width float OUTPUT)
AS
/**
 * 
 * NAME:
 * dbo.permit_calculate_max_width_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This is the SQL 2000 version of the permit_calculate_max_width_sp that 
 * calculates the max width of a trip to be used during permit requirement generation
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * @p_width float
 *
 * PARAMETERS:
 * 001 - @p_lgh_number, int, input
 *       This parameter indicates the leg number to gather dimensions information
 * 002 - @p_width, float, output, null;
 *       This is the weight value to use when generating permit requirements
 *
 * 
 * REVISION HISTORY:
 * 03/06/2006 ? PTS31766 - Jason Bauwin ? original
 * 05/22/2008 - PTS42900 - Frank Michels - increased object in @weight table to varchar(21) to prevent truncation errors
 *
 **/
declare @v_trc varchar (8), @v_trl varchar(13), @v_trl2 varchar(13)
declare @v_current_max float, @v_evaluate_value float
declare @v_mov_number int, @v_p_counter int

declare @width table (object varchar(21),
							 width  float NULL)

select @v_current_max = 0

select @v_trc = lgh_tractor,
       @v_trl = lgh_primary_trailer,
       @v_trl2 = lgh_primary_pup,
       @v_mov_number = mov_number
  from legheader
 where lgh_number = @p_lgh_number

if (select count(*)
      from permits
     where (isnull(mov_number,0) = @v_mov_number AND isnull(lgh_number,0) = 0)
        OR (isnull(mov_number,0) = 0 AND isnull(lgh_number,0) = @p_lgh_number)) > 0
begin
   select @v_p_counter = min(p_id)
     from permits
    where (isnull(mov_number,0) = @v_mov_number AND isnull(lgh_number,0) = 0)
       OR (isnull(mov_number,0) = 0 AND isnull(lgh_number,0) = @p_lgh_number)
   while @v_p_counter is not null
   begin
      --get the max width for the axle configuration of the current permit
      select @v_evaluate_value = (max(isnull(pac_width,0)))
        from permit_axle_configuration
       where p_id = @v_p_counter
      --set the max value
      if @v_evaluate_value > @v_current_max
        begin
          select @v_current_max = @v_evaluate_value
        end
      --loop to the next permit
      select @v_p_counter = min(p_id)
        from permits
-- PTS 34740 -- BL (start)
--       where (isnull(mov_number,0) = @v_mov_number AND isnull(lgh_number,0) = 0)
--          OR (isnull(mov_number,0) = 0 AND isnull(lgh_number,0) = @p_lgh_number)
       where ((isnull(mov_number,0) = @v_mov_number AND isnull(lgh_number,0) = 0)
          OR (isnull(mov_number,0) = 0 AND isnull(lgh_number,0) = @p_lgh_number))
-- PTS 34740 -- BL (end)
         and p_id > @v_p_counter
   end
end
if @v_current_max > 0
begin
   --if the current max is > 0 then use the longest axle configuration for the width
   insert into @width (object, width)
   select 'FULLCONFIG', @v_current_max
end
else
begin
   insert into @width (object, width)
   select 'TRL',max(isnull(pac_width,0))
     from permit_axle_configuration
    where asgn_type = 'TRL'
      and isnull(p_id,0) = 0
      and asgn_id = @v_trl
   
   insert into @width (object, width)
   select 'TRL2',max(isnull(pac_width,0))
     from permit_axle_configuration
    where asgn_type = 'TRL'
      and isnull(p_id,0) = 0
      and asgn_id = @v_trl2
end

--factor in width of commodity, first take from the frightdetail if that is not present take from the commodity profile
insert into @width (object, width)
select 'Trip Cmd - ' + freightdetail.cmd_code, max(freightdetail.fgt_width)
  from freightdetail
  join stops on stops.stp_number = freightdetail.stp_number
 where freightdetail.cmd_code <> 'UNKNOWN'
   and stops.lgh_number = @p_lgh_number
 group by freightdetail.cmd_code

update @width
   set object = 'Master Cmd - ' + cmd_code, width = cmd_default_width
  from commodity
 where object = 'Trip Cmd - ' + commodity.cmd_code
   and isnull(width,0) = 0

select @p_width = max(isnull(width,0))
  from @width

GO
GRANT EXECUTE ON  [dbo].[permit_calculate_max_width_sp] TO [public]
GO
