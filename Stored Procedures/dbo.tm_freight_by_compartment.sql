SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_freight_by_compartment] @stp_number int, @stp_type char(3)

AS

SET NOCOUNT ON

CREATE TABLE #tmp(seq int)
INSERT #tmp VALUES(1)
INSERT #tmp VALUES(2)
INSERT #tmp VALUES(3)
INSERT #tmp VALUES(4)
INSERT #tmp VALUES(5)
INSERT #tmp VALUES(6)
INSERT #tmp VALUES(7)
INSERT #tmp VALUES(8)

IF @stp_type='DRP'
	SELECT  isnull(f.cmd_code,'') + ' ' + isnull(f.fgt_description,'') cmd, 
		f.fbc_compartm_capacity maxvol, 
		f.fbc_volume vol, 
		f.fbc_weight wgt, 
		f.cpr_density dens, 
		f.tank_loc
	  FROM freight_by_compartment f (NOLOCK)
	  LEFT JOIN #tmp t
	  ON t.seq = f.fbc_compartm_number
	 WHERE f.stp_number=@stp_number  
     ORDER BY t.seq, isnull(cmd_code,'9999')
ELSE
	SELECT  isnull(f.cmd_code,'') + ' ' + isnull(f.fgt_description,'') cmd, 
		f.fbc_compartm_capacity maxvol, 
		f.fbc_volume vol, 
		f.fbc_weight wgt, 
		f.cpr_density dens, 
		f.tank_loc
	  FROM freight_by_compartment f(NOLOCK)
	  LEFT JOIN #tmp t ON t.seq = f.fbc_compartm_number
	 WHERE f.stp_number_load=@stp_number 
     ORDER BY t.seq, isnull(cmd_code,'9999')

DROP TABLE #tmp

GO
GRANT EXECUTE ON  [dbo].[tm_freight_by_compartment] TO [public]
GO
