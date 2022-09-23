SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_pickListCreate]
    @label_labeldefinition varchar(20),
    @label_name varchar(20),
    @label_abbr varchar(6),
    @label_code int,
    @label_userlabelname varchar(20),
    @label_retired char(1)
AS
INSERT INTO [labelfile] (
    labeldefinition,
    name,
    abbr,
    code,
    userlabelname,
    retired
)
VALUES (
    @label_labeldefinition,
    @label_name,
    @label_abbr,
    @label_code,
    @label_userlabelname,
    @label_retired
)



GO
GRANT EXECUTE ON  [dbo].[core_pickListCreate] TO [public]
GO
