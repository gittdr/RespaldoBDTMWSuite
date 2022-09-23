SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO









CREATE     Procedure [dbo].[DriverAwareSuite_DriverFilterList]

As

Select   CodeName = Parameter_Name,
	 --uncomment for infragistics --FieldType = Pres_Name, 
	 DisplayName = Case When Label_Definition Is Not Null and LabelAbbr Is Null Then 			
				IsNull((select Top 1 case when RTrim(labelfile.userlabelname) = '' Then Pres_Name else IsNull(labelfile.userlabelname,Pres_Name) end from labelfile (NOLOCK) where labeldefinition = Label_Definition),Pres_Name)
			    When Label_Definition Is Not Null and LabelAbbr Is Not Null Then
				IsNull((select Top 1 case when RTrim(labelfile.userlabelname) = '' Then Pres_Name else IsNull(labelfile.name,Pres_Name) end from labelfile (NOLOCK) where labeldefinition = Label_Definition and abbr = LabelAbbr),Pres_Name)
			    Else
				Pres_Name
		       End
			       
From     DriverAwareSuite_LabelMappings
Order By Sort_Order







GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DriverFilterList] TO [public]
GO
