SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create function [dbo].[CheckLabel](@value varchar(6), @labeldef varchar(20), @allownull int=1) returns int as begin return dbo.CheckLabel_r(@value, @labeldef, @allownull) end
GO
