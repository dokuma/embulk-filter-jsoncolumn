# Jsoncolumn filter plugin for Embulk

Extract json from input json.

## Overview

* **Plugin type**: filter

## Configuration

- schema: description (array, default: [], required)

### schema

Array of schema definition. Schema name, type must be same as output column.

- name: name of schema (string, required)
- type: type of schema (string, required)
- path: JsonPath (string, optional)

## Example

Sample data.

```json
"root": {
	    "cluster_name": "fuga",
	    "nodes": {
	        "hoge": {
	            "timestamp": 1466645114192,
	
	             .
	             .
	             .
	             .
	
	         }
	    },
	    "status": {
	    }
	}
}
```

Sample config.

```yaml
filters:
  - type: jsoncolumn
    schema:
      - {name: cluster_name, type: string, path: "$..cluster_name"}
      - {name: nodes, type: string, path: "$..nodes"}
```

Result.

```json
{
    "cluster_name": "fuga",
    "nodes": {
        "hoge": {
            "timestamp": 1466645114192,

             .
             .
             .
             .

         }
    }
}
```

## Build

```
$ rake
```
