CREATE TABLE country_energy_table2 (
  Domain_Code varchar(1000) DEFAULT NULL,
  Domain_txt varchar(1000) DEFAULT NULL,
  Area_Code int DEFAULT NULL,
  Area_txt varchar(1000) DEFAULT NULL,
  Element_Code int DEFAULT NULL,
  Element_txt varchar(1000) DEFAULT NULL,
  Item_Code int DEFAULT NULL,
  Item_txt varchar(1000) DEFAULT NULL,
  Year_Code int DEFAULT NULL,
  Year_num varchar(1000) DEFAULT NULL,
  Unit_txt varchar(1000) DEFAULT NULL,
  Value_num decimal(16,7) DEFAULT NULL,
  Flag_code varchar(1000) DEFAULT NULL,
  Flag_Description varchar(1000) DEFAULT NULL
);

INSERT INTO country_energy_table2
SELECT * FROM country_energy_table;

CREATE TABLE relevant_energy_info AS
   SELECT area_txt, item_txt, value_num
   FROM country_energy_table2;
   
CREATE VIEW gas_diesel_oil AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Gas-Diesel oil'
ORDER BY value_num DESC;

CREATE VIEW motor_gas AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Motor Gasoline'
ORDER BY value_num DESC;

CREATE VIEW natural_gas AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Natural gas (including LNG)'
ORDER BY value_num DESC;

CREATE VIEW coal AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Coal'
ORDER BY value_num DESC;

CREATE VIEW electricity AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Electricity'
ORDER BY value_num DESC;

CREATE VIEW liq_pg AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Liquefied petroleum gas (LPG)'
ORDER BY value_num DESC;

CREATE VIEW fuel_oil AS
SELECT * FROM relevant_energy_info
WHERE item_txt='Fuel oil'
ORDER BY value_num DESC;

CREATE TABLE overall_energy AS
SELECT * from relevant_energy_info 
WHERE item_txt = 'Total Energy'
ORDER BY value_num DESC;


SET @total_global_amt := (SELECT SUM(value_num) FROM overall_energy);

SELECT *, (value_num/ @total_global_amt) AS prop_global_total
FROM overall_energy;

CREATE VIEW coal_prop AS SELECT overall_energy.area_txt, (coal.value_num/overall_energy.value_num) AS prop_coal  
	FROM (overall_energy
	LEFT JOIN coal ON overall_energy.area_txt = coal.area_txt);
	
CREATE VIEW elec_prop AS SELECT overall_energy.area_txt,(electricity.value_num/overall_energy.value_num) AS prop_electricity  
	FROM (overall_energy
	LEFT JOIN electricity ON overall_energy.area_txt = electricity.area_txt);
    
CREATE VIEW fuel_prop AS SELECT overall_energy.area_txt,(fuel_oil.value_num/overall_energy.value_num) AS prop_fuel_oil
	FROM (overall_energy
	LEFT JOIN fuel_oil ON overall_energy.area_txt = fuel_oil.area_txt);
    
CREATE VIEW gdo_prop AS SELECT overall_energy.area_txt, (gas_diesel_oil.value_num/overall_energy.value_num) AS prop_gas_diesel_oil  
	FROM (overall_energy
	LEFT JOIN gas_diesel_oil ON overall_energy.area_txt = gas_diesel_oil.area_txt);

CREATE VIEW liqpg_prop AS SELECT overall_energy.area_txt, (liq_pg.value_num/overall_energy.value_num) AS prop_liq_pg 
	FROM (overall_energy
	LEFT JOIN liq_pg ON overall_energy.area_txt = liq_pg.area_txt);

CREATE VIEW motor_prop AS SELECT overall_energy.area_txt, (motor_gas.value_num/overall_energy.value_num) AS prop_motor_gas 
	FROM (overall_energy
	LEFT JOIN motor_gas ON overall_energy.area_txt = motor_gas.area_txt);

CREATE VIEW ng_prop AS SELECT overall_energy.area_txt, (natural_gas.value_num/overall_energy.value_num) AS prop_natural_gas  
	FROM (overall_energy
	LEFT JOIN natural_gas ON overall_energy.area_txt = natural_gas.area_txt);
    
CREATE VIEW with_props AS 
	SELECT overall_energy.*, coal_prop.prop_coal, elec_prop.prop_electricity, fuel_prop.prop_fuel_oil,
			gdo_prop.prop_gas_diesel_oil, liqpg_prop.prop_liq_pg, motor_prop.prop_motor_gas, ng_prop.prop_natural_gas
	FROM (overall_energy
	JOIN coal_prop ON overall_energy.area_txt = coal_prop.area_txt
    JOIN elec_prop ON overall_energy.area_txt = elec_prop.area_txt
    JOIN fuel_prop ON overall_energy.area_txt = fuel_prop.area_txt
    JOIN gdo_prop ON overall_energy.area_txt = gdo_prop.area_txt
    JOIN liqpg_prop ON overall_energy.area_txt = liqpg_prop.area_txt
    JOIN motor_prop ON overall_energy.area_txt = motor_prop.area_txt
    JOIN ng_prop ON overall_energy.area_txt = ng_prop.area_txt);
    
