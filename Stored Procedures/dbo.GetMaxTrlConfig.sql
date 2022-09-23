SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE PROCEDURE [dbo].[GetMaxTrlConfig] (@trlConfigList as varchar (4000), @trlConfig varchar (6) output)  
AS  
BEGIN  
  DECLARE @maxaxles INTEGER  
    
  SELECT @maxaxles = max (ISNull (ech_axles,0))   
   FROM dbo.CSVStringsToTable_fn (@trlConfigList) join equipmentconfigheader on value = ech_train_config  
  SELECT top 1 @trlConfig = ech_train_config   
   FROM equipmentconfigheader  
   WHERE ech_axles = @maxaxles
  IF @trlConfig IS NULL SELECT @trlconfig = 'UNK'  
END  
GO
GRANT EXECUTE ON  [dbo].[GetMaxTrlConfig] TO [public]
GO
