SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE    Procedure [dbo].[DriverAwareSuite_SetProperties] (@Key varchar(255),@Value varchar (255),@Type varchar(255))

As



IF EXISTS(SELECT * FROM DriverAwareSuite_GeneralInfo WHERE dsat_key = @Key) 
Update DriverAwareSuite_GeneralInfo Set dsat_value = @Value Where dsat_key = @Key and dsat_type = @Type
ELSE 
Insert into DriverAwareSuite_GeneralInfo (dsat_key,dsat_value,dsat_type) Values (@Key,@Value,@Type)





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_SetProperties] TO [public]
GO
