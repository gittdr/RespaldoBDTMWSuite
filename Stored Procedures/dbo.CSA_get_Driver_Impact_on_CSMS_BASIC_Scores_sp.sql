SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores_sp] (
	@query_id varchar(30),
	@As_Of_Date datetime,
	@As_Of_DateSpecified varchar(5),
	@Cargo_Related_Factor			float,
	@Cargo_Related_FactorSpecified	varchar(5),
	@Cargo_Related_Rank				float,
	@Cargo_Related_RankSpecified	varchar(5),
	@Carrier						varchar(100),
	@Controlled_Substances_Factor	float,
	@Controlled_Substances_FactorSpecified	varchar(5),
	@Controlled_Substances_Rank		float,
	@Controlled_Substances_RankSpecified	varchar(5),
	@DOT_Number						varchar(30),
	@Driver							varchar(100),
	@Driver_Fitness_Factor			float,
	@Driver_Fitness_FactorSpecified	varchar(5),
	@Driver_Fitness_Rank			float,
	@Driver_Fitness_RankSpecified	varchar(5),
	@Driver_License_Number			varchar(30),
	@Driver_License_State			varchar(30),
	@Fatigued_Driving_Factor		float,
	@Fatigued_Driving_FactorSpecified	varchar(5),
	@Fatigued_Driving_Rank			float,
	@Fatigued_Driving_RankSpecified	varchar(5),
	@Unsafe_Driving_Factor			float,
	@Unsafe_Driving_FactorSpecified	varchar(5),
	@Unsafe_Driving_Rank			float,
	@Unsafe_Driving_RankSpecified	varchar(5),
	@Vehicle_Maintenance_Factor		float,
	@Vehicle_Maintenance_FactorSpecified	varchar(5),
	@Vehicle_Maintenance_Rank		float,
	@Vehicle_Maintenance_RankSpecified	varchar(5)
        )
AS

/**
 * 
 * NAME:
 * dbo.CSA_get_Driver_Impact_on_CSMS_BASIC_Scores_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to populate the CSA table CSA_get_Driver_Impact_on_CSMS_BASIC_Scores
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

	INSERT INTO CSA_get_Driver_Impact_on_CSMS_BASIC_Scores
		(query_id,
		As_Of_Date,
		As_Of_DateSpecified,
		Cargo_Related_Factor,
		Cargo_Related_FactorSpecified,
		Cargo_Related_Rank,
		Cargo_Related_RankSpecified,
		Carrier,
		Controlled_Substances_Factor,
		Controlled_Substances_FactorSpecified,
		Controlled_Substances_Rank,
		Controlled_Substances_RankSpecified,
		DOT_Number,
		Driver,
		Driver_Fitness_Factor,
		Driver_Fitness_FactorSpecified,
		Driver_Fitness_Rank,
		Driver_Fitness_RankSpecified,
		Driver_License_Number,
		Driver_License_State,
		Fatigued_Driving_Factor,
		Fatigued_Driving_FactorSpecified,
		Fatigued_Driving_Rank,
		Fatigued_Driving_RankSpecified,
		Unsafe_Driving_Factor,
		Unsafe_Driving_FactorSpecified,
		Unsafe_Driving_Rank,
		Unsafe_Driving_RankSpecified,
		Vehicle_Maintenance_Factor,
		Vehicle_Maintenance_FactorSpecified,
		Vehicle_Maintenance_Rank,
		Vehicle_Maintenance_RankSpecified)
     VALUES (
		@query_id,
		@As_Of_Date,
		@As_Of_DateSpecified,
		@Cargo_Related_Factor,
		@Cargo_Related_FactorSpecified,
		@Cargo_Related_Rank,
		@Cargo_Related_RankSpecified,
		@Carrier,
		@Controlled_Substances_Factor,
		@Controlled_Substances_FactorSpecified,
		@Controlled_Substances_Rank,
		@Controlled_Substances_RankSpecified,
		@DOT_Number,
		@Driver,
		@Driver_Fitness_Factor,
		@Driver_Fitness_FactorSpecified,
		@Driver_Fitness_Rank,
		@Driver_Fitness_RankSpecified,
		@Driver_License_Number,
		@Driver_License_State,
		@Fatigued_Driving_Factor,
		@Fatigued_Driving_FactorSpecified,
		@Fatigued_Driving_Rank,
		@Fatigued_Driving_RankSpecified,
		@Unsafe_Driving_Factor,
		@Unsafe_Driving_FactorSpecified,
		@Unsafe_Driving_Rank,
		@Unsafe_Driving_RankSpecified,
		@Vehicle_Maintenance_Factor,
		@Vehicle_Maintenance_FactorSpecified,
		@Vehicle_Maintenance_Rank,
		@Vehicle_Maintenance_RankSpecified)


	--End	


GO
GRANT EXECUTE ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores_sp] TO [public]
GO
