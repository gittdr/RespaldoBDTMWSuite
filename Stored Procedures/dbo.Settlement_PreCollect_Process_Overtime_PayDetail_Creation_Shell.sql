SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BEGIN CREATE procedure shell 'Settlement_PreCollect_Process_Overtime_PayDetail_Creation_Shell' for .NET Overtime Pay calculations                                              |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[Settlement_PreCollect_Process_Overtime_PayDetail_Creation_Shell] 
(
	@pl_pyhnumber INT, 
	@ps_asgn_type VARCHAR(6),
	@ps_asgn_id VARCHAR(13),
	@pdt_payperiod DATETIME, 
	@psd_id INT
)
AS

DECLARE @proc_name VARCHAR(60)
DECLARE @out TABLE (payDetailId INT)

SET @proc_name = (SELECT gi_string2 FROM generalinfo WHERE gi_name = 'HourlyOTPay')

INSERT INTO @out
EXEC @proc_name @pl_pyhnumber, @ps_asgn_type, @ps_asgn_id, @pdt_payperiod, @psd_id

SELECT * FROM @out

GO
GRANT EXECUTE ON  [dbo].[Settlement_PreCollect_Process_Overtime_PayDetail_Creation_Shell] TO [public]
GO
