SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[CSA_Consolidate_Raw_Data_sp] (
		@Query_ID  varchar(40)
        )
AS

/**
 * 
 * NAME:
 * dbo.CSA_Consolidate_Raw_Data_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to consolidate raw CSA data to TMWSuite tables
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
 * 08/22/2011 PTS58291 - vjh - new proc to consolidate raw CSA data to TMWSuite tables
 */
 
--  Sample call 
--						CSA_Consolidate_Raw_Data_sp  408517014478009	
 
declare @CSACargo varchar(60)
declare @CSAFitness varchar(60)
declare @CSAFatigue varchar(60)
declare @CSAUnsafe varchar(60)
declare @CSAVehicle varchar(60)
declare @CSACSA varchar(60)
 
select @CSACargo = gi_string4 from generalinfo where gi_name = 'CSACargo'
select @CSAFitness = gi_string4 from generalinfo where gi_name = 'CSAFitness'
select @CSAFatigue = gi_string4 from generalinfo where gi_name = 'CSAFatigue'
select @CSAUnsafe = gi_string4 from generalinfo where gi_name = 'CSAUnsafe'
select @CSAVehicle = gi_string4 from generalinfo where gi_name = 'CSAVehicle'
select @CSACSA = gi_string4 from generalinfo where gi_name = 'CSACSA'

delete CSAData

update CSA_get_Driver_Impact_on_CSMS_BASIC_Scores
set CSA_get_Driver_Impact_on_CSMS_BASIC_Scores.mpp_id = m.mpp_id
from manpowerprofile m
where driver = mpp_firstname + ' ' + mpp_lastname and query_id = @Query_ID

update [CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
set [CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores].mpp_id = m.mpp_id
from manpowerprofile m
where driver = mpp_firstname + ' ' + mpp_lastname and query_id = @Query_ID


insert CSAData (
Query_ID ,mpp_id ,csa_licensenumber ,csa_licensestate ,As_Of_Date
,Cargo_Related_Factor,Cargo_Related_Rank,Cargo_Related_Inspection,Cargo_Related_Basic,Cargo_Related_Serious,Cargo_Related_Over
,Controlled_Substances_Factor,Controlled_Substances_Rank,Controlled_Substances_Inspection,Controlled_Substances_Basic,Controlled_Substances_Serious,Controlled_Substances_Over
,Driver_Fitness_Factor,Driver_Fitness_Rank,Driver_Fitnes_Inspection,Driver_Fitnes_Basic,Driver_Fitnes_Serious,Driver_Fitnes_Over
,Fatigued_Driving_Factor,Fatigued_Driving_Rank,Fatigued_Driving_Inspection,Fatigued_Driving_Basic,Fatigued_Driving_Serious,Fatigued_Driving_Over
,Unsafe_Driving_Factor,Unsafe_Driving_Rank,Unsafe_Driving_Inspection,Unsafe_Driving_Basic,Unsafe_Driving_Serious,Unsafe_Driving_Over
,Vehicle_Maintenance_Factor,Vehicle_Maintenance_Rank,Vehicle_Maintenance_Inspection,Vehicle_Maintenance_Basic,Vehicle_Maintenance_Serious,Vehicle_Maintenance_Over
,Carrier
)

select @Query_ID, m.mpp_id, Driver_License_Number, Driver_License_State, As_Of_Date
,Cargo_Related_Factor, Cargo_Related_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSACargo),'N','N','N'
,Controlled_Substances_Factor, Controlled_Substances_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSACSA),'N','N','N'
,Driver_Fitness_Factor, Driver_Fitness_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSAFitness),'N','N','N'
,Fatigued_Driving_Factor, Fatigued_Driving_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSAFatigue),'N','N','N'
,Unsafe_Driving_Factor, Unsafe_Driving_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSAUnsafe),'N','N','N'
,Vehicle_Maintenance_Factor, Vehicle_Maintenance_Rank, (select count(1) 
		from CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores d 
		where d.mpp_id = b.mpp_id 
		and d.query_id = @Query_ID
		and BASIC = @CSAVehicle),'N','N','N'
,Carrier
 from CSA_get_Driver_Impact_on_CSMS_BASIC_Scores b
 join manpowerprofile m on m.mpp_id = b.mpp_id
where query_id = @Query_ID


--insert CSAData (
--Query_ID ,mpp_id ,csa_licensenumber ,csa_licensestate ,As_Of_Date
--,Cargo_Related_Factor,Cargo_Related_Rank,Cargo_Related_Inspection,Cargo_Related_Basic,Cargo_Related_Serious,Cargo_Related_Over
--,Controlled_Substances_Factor,Controlled_Substances_Rank,Controlled_Substances_Inspection,Controlled_Substances_Basic,Controlled_Substances_Serious,Controlled_Substances_Over
--,Driver_Fitness_Factor,Driver_Fitness_Rank,Driver_Fitnes_Inspection,Driver_Fitnes_Basic,Driver_Fitnes_Serious,Driver_Fitnes_Over
--,Fatigued_Driving_Factor,Fatigued_Driving_Rank,Fatigued_Driving_Inspection,Fatigued_Driving_Basic,Fatigued_Driving_Serious,Fatigued_Driving_Over
--,Unsafe_Driving_Factor,Unsafe_Driving_Rank,Unsafe_Driving_Inspection,Unsafe_Driving_Basic,Unsafe_Driving_Serious,Unsafe_Driving_Over
--,Vehicle_Maintenance_Factor,Vehicle_Maintenance_Rank,Vehicle_Maintenance_Inspection,Vehicle_Maintenance_Basic,Vehicle_Maintenance_Serious,Vehicle_Maintenance_Over
--,Carrier
--)

--values 
--(
--@Query_ID ,'AVEJI' ,'NL454545' ,'OH' ,getdate()
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,45,45,1,'Y','Y','N'
--,0,0,0,'N','N','N'
--,'An Average Carrier'
--)


--insert CSAData (
--Query_ID ,mpp_id ,csa_licensenumber ,csa_licensestate ,As_Of_Date
--,Cargo_Related_Factor,Cargo_Related_Rank,Cargo_Related_Inspection,Cargo_Related_Basic,Cargo_Related_Serious,Cargo_Related_Over
--,Controlled_Substances_Factor,Controlled_Substances_Rank,Controlled_Substances_Inspection,Controlled_Substances_Basic,Controlled_Substances_Serious,Controlled_Substances_Over
--,Driver_Fitness_Factor,Driver_Fitness_Rank,Driver_Fitnes_Inspection,Driver_Fitnes_Basic,Driver_Fitnes_Serious,Driver_Fitnes_Over
--,Fatigued_Driving_Factor,Fatigued_Driving_Rank,Fatigued_Driving_Inspection,Fatigued_Driving_Basic,Fatigued_Driving_Serious,Fatigued_Driving_Over
--,Unsafe_Driving_Factor,Unsafe_Driving_Rank,Unsafe_Driving_Inspection,Unsafe_Driving_Basic,Unsafe_Driving_Serious,Unsafe_Driving_Over
--,Vehicle_Maintenance_Factor,Vehicle_Maintenance_Rank,Vehicle_Maintenance_Inspection,Vehicle_Maintenance_Basic,Vehicle_Maintenance_Serious,Vehicle_Maintenance_Over
--,Carrier
--)

--values 
--(
--@Query_ID ,'BADJO' ,'RE698741' ,'OH' ,getdate()
--,0,0,0,'N','N','N'
--,45,45,1,'Y','Y','Y'
--,0,0,0,'N','N','N'
--,30,30,2,'Y','N','N'
--,65,65,3,'Y','Y','N'
--,15,15,1,'Y','N','N'
--,'An Average Carrier'
--)

--insert CSAData (
--Query_ID ,mpp_id ,csa_licensenumber ,csa_licensestate ,As_Of_Date
--,Cargo_Related_Factor,Cargo_Related_Rank,Cargo_Related_Inspection,Cargo_Related_Basic,Cargo_Related_Serious,Cargo_Related_Over
--,Controlled_Substances_Factor,Controlled_Substances_Rank,Controlled_Substances_Inspection,Controlled_Substances_Basic,Controlled_Substances_Serious,Controlled_Substances_Over
--,Driver_Fitness_Factor,Driver_Fitness_Rank,Driver_Fitnes_Inspection,Driver_Fitnes_Basic,Driver_Fitnes_Serious,Driver_Fitnes_Over
--,Fatigued_Driving_Factor,Fatigued_Driving_Rank,Fatigued_Driving_Inspection,Fatigued_Driving_Basic,Fatigued_Driving_Serious,Fatigued_Driving_Over
--,Unsafe_Driving_Factor,Unsafe_Driving_Rank,Unsafe_Driving_Inspection,Unsafe_Driving_Basic,Unsafe_Driving_Serious,Unsafe_Driving_Over
--,Vehicle_Maintenance_Factor,Vehicle_Maintenance_Rank,Vehicle_Maintenance_Inspection,Vehicle_Maintenance_Basic,Vehicle_Maintenance_Serious,Vehicle_Maintenance_Over
--,Carrier
--)

--values 
--(
--@Query_ID ,'GOOMA' ,'RJ486259' ,'OH' ,getdate()
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,'An Average Carrier'
--)

--insert CSAData (
--Query_ID ,mpp_id ,csa_licensenumber ,csa_licensestate ,As_Of_Date
--,Cargo_Related_Factor,Cargo_Related_Rank,Cargo_Related_Inspection,Cargo_Related_Basic,Cargo_Related_Serious,Cargo_Related_Over
--,Controlled_Substances_Factor,Controlled_Substances_Rank,Controlled_Substances_Inspection,Controlled_Substances_Basic,Controlled_Substances_Serious,Controlled_Substances_Over
--,Driver_Fitness_Factor,Driver_Fitness_Rank,Driver_Fitnes_Inspection,Driver_Fitnes_Basic,Driver_Fitnes_Serious,Driver_Fitnes_Over
--,Fatigued_Driving_Factor,Fatigued_Driving_Rank,Fatigued_Driving_Inspection,Fatigued_Driving_Basic,Fatigued_Driving_Serious,Fatigued_Driving_Over
--,Unsafe_Driving_Factor,Unsafe_Driving_Rank,Unsafe_Driving_Inspection,Unsafe_Driving_Basic,Unsafe_Driving_Serious,Unsafe_Driving_Over
--,Vehicle_Maintenance_Factor,Vehicle_Maintenance_Rank,Vehicle_Maintenance_Inspection,Vehicle_Maintenance_Basic,Vehicle_Maintenance_Serious,Vehicle_Maintenance_Over
--,Carrier
--)

--values 
--(
--@Query_ID ,'HANS' ,'ME147258' ,'NJ' ,getdate()
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,0,0,0,'N','N','N'
--,'A Different Carrier'
--)




--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Unsafe Driving'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JIM AVERAGE'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Failing to use seat belt while operating CMV'
--           ,'GACRW1234567'
--           ,'392.16'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'AVEJI')



--INSERT INTO [v].[dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[Cargo_Related_Factor]
--           ,[Cargo_Related_FactorSpecified]
--           ,[Cargo_Related_Rank]
--           ,[Cargo_Related_RankSpecified]
--           ,[Carrier]
--           ,[Controlled_Substances_Factor]
--           ,[Controlled_Substances_FactorSpecified]
--           ,[Controlled_Substances_Rank]
--           ,[Controlled_Substances_RankSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_Fitness_Factor]
--           ,[Driver_Fitness_FactorSpecified]
--           ,[Driver_Fitness_Rank]
--           ,[Driver_Fitness_RankSpecified]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Fatigued_Driving_Factor]
--           ,[Fatigued_Driving_FactorSpecified]
--           ,[Fatigued_Driving_Rank]
--           ,[Fatigued_Driving_RankSpecified]
--           ,[Unsafe_Driving_Factor]
--           ,[Unsafe_Driving_FactorSpecified]
--           ,[Unsafe_Driving_Rank]
--           ,[Unsafe_Driving_RankSpecified]
--           ,[Vehicle_Maintenance_Factor]
--           ,[Vehicle_Maintenance_FactorSpecified]
--           ,[Vehicle_Maintenance_Rank]
--           ,[Vehicle_Maintenance_RankSpecified]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'Average Carrier'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'0'
--           ,'JIM AVERAGE'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'9876543'
--           ,'AL'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,1
--           ,'True'
--           ,10
--           ,'True'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'AVEJI')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Unsafe Driving'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Speeding'
--           ,'GACRW1234567'
--           ,'392.2S'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Unsafe Driving'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Failure to obey traffic control device'
--           ,'GACRW1234567'
--           ,'392.2C'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Unsafe Driving'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Following too close'
--           ,'GACRW1234567'
--           ,'392.2FC'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')



--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Controlled Substance/Alcohol'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'On-duty use'
--           ,'GACRW1234567'
--           ,'382.205'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Fatigued Driving (HOS)'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Driver failing to retain previous 7 days? logs'
--           ,'GACRW1234567'
--           ,'395.8(k)(2)'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Fatigued Driving (HOS)'
--           ,1
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'On-board recording device information not available'
--           ,'GACRW1234567'
--           ,'395.15(g)'
--           ,1
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[BASIC]
--           ,[BASIC_Score_Impact]
--           ,[BASIC_Score_ImpactSpecified]
--           ,[Date]
--           ,[Date_of_Birth]
--           ,[Date_of_BirthSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Level]
--           ,[Linked_Vehicle_License_Number]
--           ,[Linked_Vehicle_License_State]
--           ,[Linked_Vehicle_Type]
--           ,[Linked_VIN]
--           ,[Out_of_Service]
--           ,[Regulation_Description]
--           ,[Report_Number]
--           ,[Section_Code]
--           ,[Severity]
--           ,[SeveritySpecified]
--           ,[Time_Weight]
--           ,[Time_WeightSpecified]
--           ,[Vehicle_License_Number]
--           ,[Vehicle_License_State]
--           ,[Vehicle_Type]
--           ,[VIN]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,'Vehicle Maintenance'
--           ,6.15384615384615
--           ,'T'
--           ,'7/22/2010'
--           ,'1953-12-17'
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,'9876543'
--           ,'AL'
--           ,'3'
--           ,'None'
--           ,'XX'
--           ,'None'
--           ,'None'
--           ,''
--           ,'Tires (general)'
--           ,'GACRW1234567'
--           ,'396.3A1T'
--           ,8
--           ,'True'
--           ,'1'
--           ,'True'
--           ,'BR549'
--           ,'AL'
--           ,'Truck Tractor'
--           ,'1XKDDB9X67J123456'
--           ,'BADJO')


--INSERT INTO [v].[dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores]
--           ([query_id]
--           ,[As_Of_Date]
--           ,[As_Of_DateSpecified]
--           ,[Cargo_Related_Factor]
--           ,[Cargo_Related_FactorSpecified]
--           ,[Cargo_Related_Rank]
--           ,[Cargo_Related_RankSpecified]
--           ,[Carrier]
--           ,[Controlled_Substances_Factor]
--           ,[Controlled_Substances_FactorSpecified]
--           ,[Controlled_Substances_Rank]
--           ,[Controlled_Substances_RankSpecified]
--           ,[DOT_Number]
--           ,[Driver]
--           ,[Driver_Fitness_Factor]
--           ,[Driver_Fitness_FactorSpecified]
--           ,[Driver_Fitness_Rank]
--           ,[Driver_Fitness_RankSpecified]
--           ,[Driver_License_Number]
--           ,[Driver_License_State]
--           ,[Fatigued_Driving_Factor]
--           ,[Fatigued_Driving_FactorSpecified]
--           ,[Fatigued_Driving_Rank]
--           ,[Fatigued_Driving_RankSpecified]
--           ,[Unsafe_Driving_Factor]
--           ,[Unsafe_Driving_FactorSpecified]
--           ,[Unsafe_Driving_Rank]
--           ,[Unsafe_Driving_RankSpecified]
--           ,[Vehicle_Maintenance_Factor]
--           ,[Vehicle_Maintenance_FactorSpecified]
--           ,[Vehicle_Maintenance_Rank]
--           ,[Vehicle_Maintenance_RankSpecified]
--           ,[mpp_id])
--     VALUES
--           (@Query_ID
--           ,'2011-09-07 00:00:00.000'
--           ,'True'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'Average Carrier'
--           ,1
--           ,'True'
--           ,20
--           ,'True'
--           ,'0'
--           ,'JOE BADD'
--           ,0
--           ,'True'
--           ,0
--           ,'True'
--           ,'9876543'
--           ,'AL'
--           ,2
--           ,'True'
--           ,25
--           ,'True'
--           ,3
--           ,'True'
--           ,45
--           ,'True'
--           ,1
--           ,'True'
--           ,10
--           ,'True'
--           ,'BADJO')





exec CSA_create_expirations_sp @Query_ID

GO
GRANT EXECUTE ON  [dbo].[CSA_Consolidate_Raw_Data_sp] TO [public]
GO
