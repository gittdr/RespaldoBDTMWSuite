SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_combine_axle_config] ( @p_trc varchar(8), @p_trl varchar(8), @p_trl2 varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_combine_axle_config
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure combines all the default axle configurations from a trip (tractor, trailer, trailer 2)
 * To return the total configuration
 *
 *
 * RESULT SETS: 
 * asset				This is the resource that the axle pertains to
 * unit_axlenum			Axle Number for that resource (resets on each new resource)
 * config_axlenum		Axle Number for the total configuration
 * axle_tiresize		Tiresize for this axle
 * axle_tirecount		Number of tires on the axle
 * prev_dist			Distance from previous point to this Axle
 * end_dist				Distance from this axle to end of the unit (only valid on the last axle of each resource)
 * dist_sofar			Distance from the beginning of the configuration to the end of the current row's axle
 * axle_width			Width of the Axle
 * load_weight			Load weight of the axle
 * max_weight			Maximum weight for the axle
 *
 * PARAMETERS:
 * 001 - @p_trc, varchar(8)
 *       This parameter is the tractor for the axle configuration
 * 002 - @p_trl, varchar(8)
 *       This parameter is the trailer for the axle configuration
 * 003 - @p_trl2, varchar(8)
 *       This parameter is the trailer 2 for the axle configuration
 *
 * REFERENCES: NONE
 */

--PTS 29289 11/14/05 Add PAC_ScaledWeightType

declare @counter int, @table_count int

create table #config (asset varchar(4) NULL, 
                      unit_axlenum tinyint,
                      config_axlenum int IDENTITY (1,1),
                      axle_tiresize smallint NULL,
                      axle_tirecount tinyint NULL,
                      prev_dist float NULL,
                      end_dist float NULL,
                      dist_sofar float NULL,
                      axle_width float NULL,
                      load_weight int NULL,
                      max_weight int NULL,
                      pac_tirespec varchar(20) NULL, 
                      pac_tirerating int NULL,
		      PAC_ScaledWeightType varchar(6) NULL)

insert into #config (asset, 
                     unit_axlenum,
                     axle_tiresize, 
                     axle_tirecount, 
                     prev_dist, 
                     end_dist,
                     load_weight,
                     max_weight,
                     axle_width,
                     pac_tirespec,
                     pac_tirerating,
		     PAC_ScaledWeightType)

select 'TRC', pac_AxleNumber, pac_tiresize, pac_tirecount, pac_previousdistance, pac_pad, pac_loadweight, pac_maxweight, pac_width, pac_tirespec, pac_tirerating, PAC_ScaledWeightType
  from permit_axle_configuration
 where asgn_type = 'TRC'
   and asgn_id = @p_trc
   and isnull(p_id, 0) = 0
 UNION
select 'TRL', pac_AxleNumber, pac_tiresize, pac_tirecount, pac_previousdistance, pac_pad, pac_loadweight, pac_maxweight, pac_width, pac_tirespec, pac_tirerating, PAC_ScaledWeightType
  from permit_axle_configuration
 where asgn_type = 'TRL'
   and asgn_id = @p_trl
   and asgn_id <> 'UNKNOWN'
   and isnull(p_id, 0) = 0
UNION
select 'TRL2', pac_AxleNumber, pac_tiresize, pac_tirecount, pac_previousdistance, pac_pad, pac_loadweight, pac_maxweight, pac_width, pac_tirespec, pac_tirerating, PAC_ScaledWeightType
  from permit_axle_configuration
 where asgn_type = 'TRL'
   and asgn_id = @p_trl2
   and asgn_id <> 'UNKNOWN'
   and isnull(p_id, 0) = 0
 set @counter = 2
 select @table_count = count(*) from #config
while @counter <= @table_count + 1
  begin
   update #config
      set #config.dist_sofar = (select sum(isnull(prev_dist,0.00) + isnull(end_dist,0.00))
                                  from #config c
                                 where  c.config_axlenum <= #config.config_axlenum)
   where #config.config_axlenum = @counter - 1
   set @counter = @counter + 1
  end




select asset, 
       unit_axlenum,
       axle_tiresize ,
       axle_tirecount, 
       prev_dist, 
       end_dist,
       load_weight,
       max_weight,
       axle_width,
       pac_tirespec,
       pac_tirerating,
       PAC_ScaledWeightType
from #config


GO
GRANT EXECUTE ON  [dbo].[d_combine_axle_config] TO [public]
GO
