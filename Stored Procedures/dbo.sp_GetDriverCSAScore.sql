SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetDriverCSAScore]
( @driverID            CHAR(8)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [csa_id]
      ,[Query_ID]
      ,cd.[mpp_id]
      ,[csa_licensenumber]
      ,[csa_licensestate]
      ,[As_Of_Date]
      ,[Cargo_Related_Factor]
      ,[Cargo_Related_Rank]
      ,[Cargo_Related_Inspection]
      ,[Cargo_Related_Basic]
      ,[Cargo_Related_Serious]
      ,[Cargo_Related_Over]
      ,[Controlled_Substances_Factor]
      ,[Controlled_Substances_Rank]
      ,[Controlled_Substances_Inspection]
      ,[Controlled_Substances_Basic]
      ,[Controlled_Substances_Serious]
      ,[Controlled_Substances_Over]
      ,[Driver_Fitness_Factor]
      ,[Driver_Fitness_Rank]
      ,[Driver_Fitnes_Inspection]
      ,[Driver_Fitnes_Basic]
      ,[Driver_Fitnes_Serious]
      ,[Driver_Fitnes_Over]
      ,[Fatigued_Driving_Factor]
      ,[Fatigued_Driving_Rank]
      ,[Fatigued_Driving_Inspection]
      ,[Fatigued_Driving_Basic]
      ,[Fatigued_Driving_Serious]
      ,[Fatigued_Driving_Over]
      ,[Unsafe_Driving_Factor]
      ,[Unsafe_Driving_Rank]
      ,[Unsafe_Driving_Inspection]
      ,[Unsafe_Driving_Basic]
      ,[Unsafe_Driving_Serious]
      ,[Unsafe_Driving_Over]
      ,[Vehicle_Maintenance_Factor]
      ,[Vehicle_Maintenance_Rank]
      ,[Vehicle_Maintenance_Inspection]
      ,[Vehicle_Maintenance_Basic]
      ,[Vehicle_Maintenance_Serious]
      ,[Vehicle_Maintenance_Over]
      ,[last_updateddt]
      ,[last_updatedby]
      ,cd.carrier
      ,m.mpp_lastfirst
      ,csa_licensenumber + ' (' + csa_licensestate + ')' as license
      ,As_Of_Date
      ,mpp_updateon
      ,'' as safetyrating
      ,null as ratedate
from manpowerprofile m
  left join CSAdata cd  on m.mpp_id = cd.mpp_id
where m.mpp_id = @driverID

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetDriverCSAScore] TO [public]
GO
