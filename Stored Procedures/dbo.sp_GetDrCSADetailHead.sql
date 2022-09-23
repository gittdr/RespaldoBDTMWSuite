SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_GetDrCSADetailHead]
( @queryID            CHAR(30),
@driverID  CHAR(8)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT 	      
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.As_Of_Date [AS of Date],          
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Cargo_Related_Factor [Cargo Factor],            
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Cargo_Related_Rank[Cargo Rank],        
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Carrier [Carrier],   
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Controlled_Substances_Factor[CS Factor],          
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Controlled_Substances_Rank [CS Rank],             
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Driver [Driver],   
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Driver_Fitness_Factor [Driver Fitness Factor],         
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Driver_Fitness_Rank   [Driver Fitness Rank],        
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Driver_License_Number [Drv License Number],   
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Driver_License_State [Drv License State],   
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Fatigued_Driving_Factor [Fatigued Driving Factor],             
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Fatigued_Driving_Rank [Fatigued Driving Rank],          
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Unsafe_Driving_Factor [Unsafe Driving Factor],         
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Unsafe_Driving_Rank [Unsafe Driving Rank],         
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Vehicle_Maintenance_Factor [Vehicle Maintenance Factor],          
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.Vehicle_Maintenance_Rank [Vehicle Maintenance Rank],            
         CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.mpp_id  [Mpp Id]
    FROM CSA_get_Driver_Impact_on_CSMS_BASIC_Scores
                WHERE mpp_id = @driverID
                AND   query_id = @queryID

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetDrCSADetailHead] TO [public]
GO
