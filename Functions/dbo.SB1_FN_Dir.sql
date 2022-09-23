SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SB1_FN_Dir](@Wildcard VARCHAR(8000))

RETURNS @MyDir TABLE 
(
    -- columns returned by the function
       [name] VARCHAR(2000),    --the name of the filesystem object
       [path] VARCHAR(2000),    --Contains the item's full path and name. 
       [ModifyDate] DATETIME,   --the time it was last modified 
       [IsFileSystem] INT,      --1 if it is part of the file system
       [IsFolder] INT,          --1 if it is a folsdder otherwise 0
       [error] VARCHAR(2000)    --if an error occured, gives the error otherwise null
)
AS
-- body of the function
BEGIN
   DECLARE 
       --all the objects used
       @objShellApplication INT, 
       @objFolder INT,
       @objItem INT,
       @objErrorObject INT,
       @objFolderItems INT, 
       --potential error message shows where error occurred.
       @strErrorMessage VARCHAR(1000), 
       --command sent to OLE automation
       @Command VARCHAR(1000), 
       @hr INT, --OLE result (0 if OK)
       @count INT,@ii INT,
       @name VARCHAR(2000),--the name of the current item
       @path VARCHAR(2000),--the path of the current item 
       @ModifyDate DATETIME,--the date the current item last modified
       @IsFileSystem INT, --1 if the current item is part of the file system
       @IsFolder INT --1 if the current item is a file
   --IF COALESCE(@Wildcard,'')  
            BEGIN 
                DECLARE @Source VARCHAR(255), 
                    @Description VARCHAR(255), 
                    @Helpfile VARCHAR(255), 
                    @HelpID INT 
     
                EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT, 
                    @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT 
                SELECT  @strErrorMessage = 'Error whilst ' 
                        + COALESCE(@strErrorMessage, 'doing something') + ', ' 
                        + COALESCE(@Description, '') 
                INSERT INTO @MyDir(error) SELECT  LEFT(@strErrorMessage,2000) 
            END 
        EXECUTE sp_OADestroy @objFolder 
        EXECUTE sp_OADestroy @objShellApplication

RETURN
END
GO
