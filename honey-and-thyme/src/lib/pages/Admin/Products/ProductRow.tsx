import { useState } from "react";
import type { ProductModel } from "../../../types/api";
import { HoneyModal } from "../../../components";
import ProductEdit from "./ProductEdit";

interface ProductRowProps {
  product: ProductModel;
  onUpdated: () => void;
}

function ProductRow({ product, onUpdated }: ProductRowProps) {
  const [isEditing, setIsEditing] = useState(false);

  return (
    <div
      className="im-fell-english flex cursor-pointer"
      onClick={() => setIsEditing(true)}
      key={`product-row-${product.productId}`}
    >
      <div className="min-w-0 flex-1">
        <div className="truncate text-sm font-medium">{product.name}</div>
        <div className="truncate text-xs text-gray-500">
          {product.description}
        </div>
      </div>

      <div className="flex items-center gap-2">${product.price}</div>
      {
        <HoneyModal onClose={() => setIsEditing(false)} isOpen={isEditing}>
          <ProductEdit
            product={product}
            onAfterSave={onUpdated}
            onCancel={() => setIsEditing(false)}
          />
        </HoneyModal>
      }
    </div>
  );
}
export default ProductRow;
