SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spCarrier411StopMonitoring] (@carrierID AS VARCHAR(20))
AS 
BEGIN
	DECLARE @workflow_template_id  INT
	, @workflow_nextprocesstime DATETIME
	, @workflow_id   INT --Output
	, @StartValue VARCHAR(20)
	SELECT @workflow_template_id = gi_integer1 FROM generalinfo WHERE gi_name = 'Carrier411WFT_CheckACompany'
	SET @StartValue = (SELECT COALESCE(car_iccnum, car_dotnum) FROM Carrier WHERE car_id =@carrierID)
	SELECT @workflow_nextprocesstime = getdate()
	EXEC sp_workflow_scheduler @workflow_template_id, @workflow_nextprocesstime, @StartValue, @workflow_id OUTPUT
	IF(@StartValue LIKE 'MC%'OR @StartValue LIKE 'FF%' OR @StartValue LIKE 'MX%' OR @StartValue LIKE 'T%')
	BEGIN
		INSERT INTO TMWSuite_Workflow_RequiredFields ( Workflow_ID , RequiredFieldName , RequiredFieldValue) 
		VALUES(@workflow_id, 'Docket#', @StartValue)
		UPDATE Carrier set car_411_monitored ='N' WHERE car_id=@carrierID
	END
	ELSE 
	BEGIN
		INSERT INTO TMWSuite_Workflow_RequiredFields ( Workflow_ID , RequiredFieldName , RequiredFieldValue) 
		VALUES(@workflow_id, 'Dot#', @StartValue)
		UPDATE Carrier set car_411_monitored ='N' WHERE car_id=@carrierID
	END	

	INSERT INTO TMWSuite_Workflow_RequiredFields ( Workflow_ID , RequiredFieldName , RequiredFieldValue) 
	VALUES(@workflow_id, 'StartMonitoring', 'N')
	
END
GO
GRANT EXECUTE ON  [dbo].[spCarrier411StopMonitoring] TO [public]
GO
