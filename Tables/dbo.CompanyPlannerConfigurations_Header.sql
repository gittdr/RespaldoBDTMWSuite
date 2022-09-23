CREATE TABLE [dbo].[CompanyPlannerConfigurations_Header]
(
[cph_Id] [int] NOT NULL IDENTITY(1, 1),
[cph_Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_CreatedOn] [datetime] NULL,
[cph_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cph_LastUpdatedOn] [datetime] NULL,
[cph_IsSystem] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[UpdateBoardNameOnDuplicateDescription] on [dbo].[CompanyPlannerConfigurations_Header]
AFTER INSERT AS
begin

DECLARE @addendum int = 0
DECLARE @found int = 0
DECLARE @desc varchar(max) = (select cph_description from inserted)
DECLARE @modifiedBoardDescription varchar(max)
SET @modifiedBoardDescription = @desc

set @addendum = ISNULL((select count(cph_Description) from CompanyPlannerConfigurations_Header where cph_Description = @desc or cph_Description like (@desc + '_%')), 0)

-- if there are more than 1 entry matching this name found
If @addendum > 1
begin
	-- update the description to append a suffx on the end
	set @modifiedBoardDescription = @desc + '_' + CONVERT(varchar(max), @addendum)

	-- test to make sure that one hasn't already been saved
	select @found = 1 from CompanyPlannerConfigurations_Header where upper(cph_Description) = upper(@modifiedBoardDescription)
	
	-- if a match for that name is found, then try again
	if @found = 1
	begin
		-- add to the counter and reset the found variable
		set @addendum = @addendum + 1
		set @found = 0
		set @modifiedBoardDescription = @desc + '_' + CONVERT(varchar(max), @addendum)

		-- test to make sure that one hasn't already been saved
		select @found = 1 from CompanyPlannerConfigurations_Header where cph_Description = @modifiedBoardDescription
	end
end

update CompanyPlannerConfigurations_Header set cph_description = @modifiedBoardDescription where cph_Id = (select cph_Id from inserted)

if (@modifiedBoardDescription <> @desc)
begin
	print 'updated board description to "' + @modifiedBoardDescription + '"'
end
end
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_Header] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_Header] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_Header] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_Header] TO [public]
GO
