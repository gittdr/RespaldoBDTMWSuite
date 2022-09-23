SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores_sp] (
           @query_id varchar(30),
           @As_Of_Date datetime,
           @As_Of_DateSpecified varchar(5),
           @BASIC varchar(100),
           @BASIC_Score_Impact float,
           @BASIC_Score_ImpactSpecified char(1),
           @Date varchar(30),
           @Date_of_Birth datetime,
           @Date_of_BirthSpecified varchar(5),
           @DOT_Number varchar(30),
           @Driver varchar(30),
           @Driver_License_Number varchar(30),
           @Driver_License_State varchar(30),
           @Level varchar(100),
           @Linked_Vehicle_License_Number varchar(30),
           @Linked_Vehicle_License_State varchar(30),
           @Linked_Vehicle_Type varchar(30),
           @Linked_VIN varchar(30),
           @Out_of_Service varchar(30),
           @Regulation_Description varchar(100),
           @Report_Number varchar(30),
           @Section_Code varchar(30),
           @Severity int,
           @SeveritySpecified varchar(5),
           @Time_Weight varchar(30),
           @Time_WeightSpecified varchar(5),
           @Vehicle_License_Number varchar(30),
           @Vehicle_License_State varchar(30),
           @Vehicle_Type varchar(30),
           @VIN varchar(30))
AS

/**
 * 
 * NAME:
 * dbo.CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to populate the CSA table CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * NA
 *
 * PARAMETERS:
 * See prototype above
 *
 * REVISION HISTORY:
 * 08/22/2011 PTS58291 - vjh - new proc to populate the CSA table CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores
 */
 

	--IF NOT Exists (select 1 from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores where query_id = @query_id
	--Begin

	INSERT INTO CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores
           (query_id
           ,As_Of_Date
           ,As_Of_DateSpecified
           ,BASIC
           ,BASIC_Score_Impact
           ,BASIC_Score_ImpactSpecified
           ,Date
           ,Date_of_Birth
           ,Date_of_BirthSpecified
           ,DOT_Number
           ,Driver
           ,Driver_License_Number
           ,Driver_License_State
           ,Level
           ,Linked_Vehicle_License_Number
           ,Linked_Vehicle_License_State
           ,Linked_Vehicle_Type
           ,Linked_VIN
           ,Out_of_Service
           ,Regulation_Description
           ,Report_Number
           ,Section_Code
           ,Severity
           ,SeveritySpecified
           ,Time_Weight
           ,Time_WeightSpecified
           ,Vehicle_License_Number
           ,Vehicle_License_State
           ,Vehicle_Type
           ,VIN)
     VALUES (
           @query_id,
           @As_Of_Date,
           @As_Of_DateSpecified,
           @BASIC,
           @BASIC_Score_Impact,
           @BASIC_Score_ImpactSpecified,
           @Date,
           @Date_of_Birth,
           @Date_of_BirthSpecified,
           @DOT_Number,
           @Driver,
           @Driver_License_Number,
           @Driver_License_State,
           @Level,
           @Linked_Vehicle_License_Number,
           @Linked_Vehicle_License_State,
           @Linked_Vehicle_Type,
           @Linked_VIN,
           @Out_of_Service,
           @Regulation_Description,
           @Report_Number,
           @Section_Code,
           @Severity,
           @SeveritySpecified,
           @Time_Weight,
           @Time_WeightSpecified,
           @Vehicle_License_Number,
           @Vehicle_License_State,
           @Vehicle_Type,
           @VIN)






	--End	


GO
GRANT EXECUTE ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores_sp] TO [public]
GO
