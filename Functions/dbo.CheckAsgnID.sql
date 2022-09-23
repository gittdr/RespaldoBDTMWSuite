SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create function [dbo].[CheckAsgnID](@AssignType varchar(6), @AssignID varchar(13), @allowCAR int=0, @AllowTrl2 int = 0, @Allow3rd int=0, @AllowUser int=0, @AllowExternal int=0) returns int as begin return dbo.CheckAsgnID_r(@AssignType, @AssignID, @allowCAR, @AllowTrl2, @Allow3rd, @AllowUser, @AllowExternal) end
GO
