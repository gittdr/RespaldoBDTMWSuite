SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_GetDrCSADetailDetail]
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
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.As_Of_Date [As Of Date],          
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.BASIC [Basic],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.BASIC_Score_Impact [Impact],          
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Date [Date],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Date_of_Birth [DoB],           
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.DOT_Number[Dot Number],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Driver [Driver],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Driver_License_Number [Drv License],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Driver_License_State [Drv License State],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Level [Level],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Linked_Vehicle_License_Number[Linked Vehicle License Number],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Linked_Vehicle_License_State [Linked Vehicle License State],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Linked_Vehicle_Type [Linked Vehicle Type],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Linked_VIN [Linked Vin],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Out_of_Service [Out of Service],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Regulation_Description [Regulation Description],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Report_Number [Report Number],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Section_Code [Section Code],    
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Severity [Severity],          
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Time_Weight [Time Weight],            
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Vehicle_License_Number [Vehicle License Number],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Vehicle_License_State [Vehicle License State],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.Vehicle_Type [Vehicle Type],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.VIN [Vin],   
         CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores.mpp_id  [Mpp Id]
    FROM CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores
    WHERE mpp_id = @driverID
    AND   query_id = @queryID
END
GO
GRANT EXECUTE ON  [dbo].[sp_GetDrCSADetailDetail] TO [public]
GO
