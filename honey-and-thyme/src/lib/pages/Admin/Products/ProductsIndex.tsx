import { HoneyTable } from "../../../components";
import useProducts from "../../../hooks/useProducts";
import type { ProductModel } from "../../../types/api";
import ProductEdit from "./ProductEdit";
import ProductRow from "./ProductRow";

function ProductsIndex() {
  return (
    <HoneyTable<ProductModel>
      useQuery={useProducts}
      createAddForm={(newProduct, onAfterSave, onCancel) => (
        <ProductEdit
          product={newProduct}
          onAfterSave={onAfterSave}
          onCancel={onCancel}
        />
      )}
      renderRow={(product, refetch) => (
        <>
          <ProductRow
            product={product}
            onUpdated={() => refetch && refetch()}
          />
        </>
      )}
      addInitial={() => ({})}
    />
  );
}

export default ProductsIndex;
