SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_leg_commodities_sp] (@lghnumber INT)
AS

DECLARE @fgtcomp INT, 
        @exists  INT

SELECT @exists = COUNT(*) 
  FROM sysobjects 
 WHERE name = 'freight_by_compartment'

IF @exists > 0
   SELECT @fgtcomp = COUNT(*) 
     FROM stops, 
          freightdetail, 
          freight_by_compartment 
    WHERE stops.lgh_number = @lghnumber 
      AND freightdetail.stp_number = stops.stp_number 
      AND freight_by_compartment.fgt_number = freightdetail.fgt_number 
ELSE
   SET @fgtcomp = 0

IF @fgtcomp > 0
    SELECT DISTINCT commodity.cmd_code, 
           commodity.cmd_name, 
           SUM(ISNULL(freight_by_compartment.fbc_volume, 0)) as volume, 
           SUM(ISNULL(freight_by_compartment.fbc_weight, 0)) as weight, 
           freightdetail.fgt_weightunit, 
           freightdetail.fgt_volumeunit, 
           freight_by_compartment.scm_subcode, 
           freight_by_compartment.fbc_compartm_number 
      FROM stops, 
           freightdetail, 
           freight_by_compartment, 
           commodity 
     WHERE stops.lgh_number = @lghnumber 
       AND stops.stp_type = 'DRP' 
       AND freightdetail.stp_number = stops.stp_number 
       AND freight_by_compartment.fgt_number = freightdetail.fgt_number 
       AND freight_by_compartment.cmd_code = commodity.cmd_code 
       AND freight_by_compartment.cmd_code NOT IN ('UNK', 'UNKNOWN') 
  GROUP BY commodity.cmd_code, 
           commodity.cmd_name, 
           freightdetail.fgt_weightunit, 
           freightdetail.fgt_volumeunit, 
           freight_by_compartment.scm_subcode, 
           freight_by_compartment.fbc_compartm_number 
ELSE
    SELECT freightdetail.cmd_code, 
           commodity.cmd_name, 
           SUM(ISNULL(fgt_volume, 0)) as volume, 
           SUM(ISNULL(fgt_weight, 0)) as weight, 
           freightdetail.fgt_weightunit, 
           freightdetail.fgt_volumeunit, 
           '' as scm_subcode, 
           0 as fbc_compartm_number 
      FROM stops, 
           freightdetail, 
           commodity 
     WHERE stops.lgh_number = @lghnumber 
       AND stops.stp_type = 'DRP' 
       AND freightdetail.stp_number = stops.stp_number 
       AND freightdetail.cmd_code = commodity.cmd_code 
       AND freightdetail.cmd_code NOT IN ('UNK', 'UNKNOWN') 
  GROUP BY freightdetail.cmd_code, 
           commodity.cmd_name, 
           freightdetail.fgt_weightunit, 
           freightdetail.fgt_volumeunit 
GO
GRANT EXECUTE ON  [dbo].[d_leg_commodities_sp] TO [public]
GO
