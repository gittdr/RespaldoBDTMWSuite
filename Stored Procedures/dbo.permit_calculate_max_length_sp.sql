SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permit_calculate_max_length_sp] (@p_lgh_number int, @p_length float OUTPUT)
AS
/**
 * 
 * NAME:
 * dbo.permit_calculate_max_length_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This is the SQL 2000 version of the permit_calculate_max_length_sp that 
 * calculates the max height of a trip to be used during permit requirement generation
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * @p_length float
 *
 * PARAMETERS:
 * 001 - @p_lgh_number, int, input
 *       This parameter indicates the leg number to gather dimensions information
 * 002 - @p_length, float, output, null;
 *       This is the length value to use when generating permit requirements
 *
 * 
 * REVISION HISTORY:
 * 03/06/2006 ? PTS31766 - Jason Bauwin ? original
 *
 **/
declare @v_trc varchar (8), @v_trl varchar(13), @v_trl2 varchar(13)
declare @v_current_max float, @v_evaluate_value float
declare @v_mov_number int, @v_p_counter int

declare @length table (object varchar(21),
							  length  float NULL)

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
      --get the total length for the axle configuration of the current permit
      select @v_evaluate_value = sum(isnull(pac_previousdistance,0) + isnull(pac_pad,0) + isnull(pac_overhang,0))
        from permit_axle_configuration
       where p_id = @v_p_counter
      --compare it to the current max height
      if @v_evaluate_value > @v_current_max
      begin
         --set it as the max
         select @v_current_max = @v_evaluate_value
      end
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
   --if the current max is > 0 then use the longest axle configuration for the length
   insert into @length (object, length)
   select 'FULLCONFIG', @v_current_max
end
else
begin
   --if the current max is 0 (either no permits exist or none with axle configs) use the config that is defaulted from the master file
   insert into @length (object, length)
   select 'TRC', sum(isnull(pac_previousdistance,0) + isnull(pac_pad,0))
     from permit_axle_configuration
    where asgn_id = @v_trc
      and asgn_type = 'TRC'
      and p_id is null

   insert into @length (object, length)
   select 'TRL', sum(isnull(pac_previousdistance,0) + isnull(pac_pad,0))
     from permit_axle_configuration
    where asgn_id = @v_trl
      and asgn_type = 'TRL'
      and p_id is null

   insert into @length (object, length)
   select 'TRL2', sum(isnull(pac_previousdistance,0) + isnull(pac_pad,0))
     from permit_axle_configuration
    where asgn_id = @v_trl2
      and asgn_type = 'TRL'
      and p_id is null
end

select @p_length = sum(isnull(length,0))
  from @length

GO
GRANT EXECUTE ON  [dbo].[permit_calculate_max_length_sp] TO [public]
GO
