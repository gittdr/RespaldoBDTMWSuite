SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[fnc_SSRS_TotalMailFolderName]  
      (@foldernumber as int)
returns varchar(255)
as  
 /*
 [fnc_SSRS_TotalMailFolderName]
 1/7/2013
 Jerry Ritcey
 Purpose: Return the fully qualified folder name based on a folder number
 */ 
begin  
  declare @Foldername varchar(255),@TempFolderNumber int,@Parent int
  
   set @Foldername = (Select top  1 ltrim(rtrim(Name)) from tblFolders where tblfolders.SN = @foldernumber)
  set @Parent = (select top 1 parent from tblFolders where tblfolders.SN = @foldernumber)
	
	While  @Parent is not null and @Parent <> 0
	BEGIN
	set @TempFolderNumber = @Parent
	
	set @Foldername = (Select top 1 LTRIM(rtrim(name)) from tblFolders where SN = @TempFolderNumber) + '\' +  @Foldername
	
	set @Parent = (select top 1 parent from tblFolders where tblfolders.SN = @TempFolderNumber)
	END
	
  
  
  
      return @Foldername  
end  
  
  

GO
GRANT EXECUTE ON  [dbo].[fnc_SSRS_TotalMailFolderName] TO [public]
GO
