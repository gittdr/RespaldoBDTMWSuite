SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permit_calculate_max_height_sp] (@p_lgh_number int, @p_height float OUTPUT)
AS
/**
 * 
 * NAME:
 * dbo.permit_calculate_max_height_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This is the SQL 2000 version of the permit_calculate_max_height_sp that 
 * calculates the max height of a trip to be used during permit requirement generation
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * @p_height float
 *
 * PARAMETERS:
 * 001 - @p_lgh_number, int, input
 *       This parameter indicates the leg number to gather dimensions information
 * 002 - @p_height, float, output, null;
 *       This is the height value to use when generating permit requirements
 *
 * 
 * REVISION HISTORY:
 * 03/06/2006 ? PTS31766 - Jason Bauwin ? original
 *
 **/


declare @v_trc varchar (8), @v_trl varchar(13), @v_trl2 varchar(13)

declare @height table (object varchar(21),
							  height  float NULL)


select @v_trc = lgh_tractor,
       @v_trl = lgh_primary_trailer,
       @v_trl2 = lgh_primary_pup
  from legheader
 where lgh_number = @p_lgh_number

insert into @height (object, height)
select 'TRL',isnull(trl_height,0)
  from trailerprofile
 where trl_id = @v_trl

insert into @height (object, height)
select 'TRL2',isnull(trl_height,0)
  from trailerprofile
 where trl_id = @v_trl

--factor in height of commodity, first take from the frightdetail if that is not present take from the commodity profile
if (select count(*)
     from freightdetail
     join stops on stops.stp_number = freightdetail.stp_number
    where stops.ord_hdrnumber > 0
      and stops.stp_number in (select distinct stp_number
                                 from stops
                                where stops.lgh_number = @p_lgh_number)
      and isnull(freightdetail.fgt_height,0) > 0) > 0
BEGIN
   insert into @height (object, height)
   select 'CMD - ' + freightdetail.cmd_code, freightdetail.fgt_height
     from freightdetail
    where freightdetail.fgt_number = (select min(fgt_number)
                                        from freightdetail
                                        join stops on stops.stp_number = freightdetail.stp_number
                                       where freightdetail.cmd_code <> 'UNKNOWN'
                                         and stops.lgh_number = @p_lgh_number
                                         and freightdetail.fgt_height = (select max(fgt_height)
                                                                           from freightdetail
                                                                           join stops on stops.stp_number = freightdetail.stp_number
                                                                          where freightdetail.cmd_code <> 'UNKNOWN'
                                                                            and stops.lgh_number = @p_lgh_number
                                                                            and isnull(freightdetail.fgt_height,0) > 0))
END
ELSE
BEGIN
   insert into @height (object, height)
   select 'CMD - ' + cmd_code, cmd_default_height
     from commodity
    where cmd_code in (select distinct freightdetail.cmd_code 
                        from freightdetail
                        join stops on stops.stp_number = freightdetail.stp_number
                       where stops.lgh_number = @p_lgh_number
                         and freightdetail.cmd_code <> 'UNKNOWN')
END

select @p_height = sum(isnull(height,0))
  from @height

GO
GRANT EXECUTE ON  [dbo].[permit_calculate_max_height_sp] TO [public]
GO
